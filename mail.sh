#!/bin/bash

# AUTO SCRIPT QUAN LY MAIL SERVER (ULTIMATE)
# He dieu hanh: CentOS 7 (Chuan theo video huong dan)
# Core: Postfix + Dovecot + SquirrelMail + BIND (DNS)
# Tinh nang: Quan ly dich vu, Doi mat khau, Danh sach tai khoan, Hien thi Domain

if [ "$EUID" -ne 0 ]; then
    echo "Vui long chay chuong trinh bang quyen root!"
    exit 1
fi

pause() {
    echo ""
    read -r -p "Nhan Enter de tiep tuc..."
}

install_core_mail() {
    echo "===== CAI DAT LOI MAIL SERVER VA DNS ====="
    read -r -p "Nhap ten mien cua ban (VD: sgu.edu.vn): " DOMAIN
    if [ -z "$DOMAIN" ]; then 
        echo "Loi: Ten mien khong duoc de trong!"
        return 1
    fi

    echo "[1/5] Tat SELinux va mo cong Tuong lua..."
    setenforce 0 2>/dev/null
    sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
    
    # Mo them cong dns de phan giai ten mien
    for svc in smtp pop3 imap http https dns; do
        firewall-cmd --permanent --add-service="$svc" >/dev/null 2>&1
    done
    firewall-cmd --reload >/dev/null 2>&1

    echo "[2/5] Go bo Sendmail, cai dat Postfix, Dovecot va DNS (BIND)..."
    yum remove -y sendmail >/dev/null 2>&1
    yum install -y postfix dovecot bind bind-utils epel-release >/dev/null 2>&1

    echo "[3/5] Cau hinh DNS Server (De vao Webmail bang Ten mien)..."
    # Tu dong lay IP hien tai cua may CentOS
    SERVER_IP=$(hostname -I | awk '{print $1}')
    
    sed -i 's/listen-on port 53 { 127.0.0.1; };/listen-on port 53 { any; };/g' /etc/named.conf
    sed -i 's/allow-query     { localhost; };/allow-query     { any; };/g' /etc/named.conf
    
    if ! grep -q "zone \"$DOMAIN\"" /etc/named.rfc1912.zones; then
        cat <<EOF >> /etc/named.rfc1912.zones
zone "$DOMAIN" IN {
    type master;
    file "$DOMAIN.zone";
    allow-update { none; };
};
EOF
    fi
    
    cat <<EOF > /var/named/$DOMAIN.zone
\$TTL 86400
@   IN  SOA     ns.$DOMAIN. root.$DOMAIN. ( 1 3600 1800 604800 86400 )
@   IN  NS      ns.$DOMAIN.
@   IN  MX 10   mail.$DOMAIN.
@   IN  A       $SERVER_IP
ns  IN  A       $SERVER_IP
mail IN A       $SERVER_IP
www IN  A       $SERVER_IP
EOF
    chown root:named /var/named/$DOMAIN.zone

    echo "[4/5] Cau hinh Postfix (Giao thuc SMTP gui thu)..."
    cp /etc/postfix/main.cf /etc/postfix/main.cf.bak
    postconf -e "myhostname = mail.$DOMAIN"
    postconf -e "mydomain = $DOMAIN"
    postconf -e "myorigin = \$mydomain"
    postconf -e "inet_interfaces = all"
    postconf -e "inet_protocols = ipv4"
    postconf -e "mydestination = \$myhostname, localhost.\$mydomain, localhost, \$mydomain"
    postconf -e "mynetworks = 192.168.0.0/16, 10.0.0.0/8, 127.0.0.0/8"
    postconf -e "home_mailbox = Maildir/"

    echo "[5/5] Cau hinh Dovecot (Giao thuc POP3/IMAP nhan thu)..."
    cp /etc/dovecot/dovecot.conf /etc/dovecot/dovecot.conf.bak
    sed -i 's/#protocols = imap pop3 lmtp/protocols = imap pop3 lmtp/g' /etc/dovecot/dovecot.conf
    sed -i 's/#disable_plaintext_auth = yes/disable_plaintext_auth = no/g' /etc/dovecot/conf.d/10-auth.conf
    sed -i 's/auth_mechanisms = plain/auth_mechanisms = plain login/g' /etc/dovecot/conf.d/10-auth.conf
    sed -i 's|#mail_location = |mail_location = maildir:~/Maildir|g' /etc/dovecot/conf.d/10-mail.conf

    # Khoi dong dong thoi ca DNS, Postfix va Dovecot
    systemctl enable named postfix dovecot >/dev/null 2>&1
    systemctl restart named postfix dovecot
    echo "=> Hoan tat cai dat Core Mail va DNS!"
}

install_webmail() {
    echo "===== CAI DAT WEBMAIL (SQUIRRELMAIL) ====="
    echo "[1/2] Cai dat SquirrelMail va Apache..."
    yum install -y epel-release >/dev/null 2>&1
    yum install -y squirrelmail httpd >/dev/null 2>&1
    
    echo "[2/2] Cau hinh SquirrelMail va Apache..."
    DOMAIN=$(postconf -h mydomain 2>/dev/null || echo "sgu.edu.vn")
    
    if [ -f /etc/squirrelmail/config.php ]; then
        sed -i "s/\$domain = 'example.com';/\$domain = '$DOMAIN';/g" /etc/squirrelmail/config.php
        sed -i "s/\$imap_server_type = 'uw';/\$imap_server_type = 'dovecot';/g" /etc/squirrelmail/config.php
    fi
    
    cat <<EOF > /etc/httpd/conf.d/squirrelmail.conf
Alias /webmail /usr/share/squirrelmail
<Directory /usr/share/squirrelmail>
    Options None
    AllowOverride None
    Require all granted
</Directory>
EOF
    
    systemctl enable httpd >/dev/null 2>&1
    systemctl restart httpd
    echo "=> Hoan tat! Truy cap Webmail tai: http://$DOMAIN/webmail"
}

manage_user() {
    echo "===== TAO TAI KHOAN EMAIL ====="
    read -r -p "Nhap ten tai khoan can tao (VD: sinhvien1): " usr
    if id "$usr" &>/dev/null; then
        echo "Loi: Tai khoan '$usr' da ton tai tren he thong!"
    else
        useradd -m "$usr"
        echo "*** LUU Y: Mat khau phai bao gom chu hoa, chu thuong, so va ky tu dac biet ***"
        passwd "$usr"
        echo "=> Tao tai khoan email $usr thanh cong."
    fi
}

change_password() {
    echo "===== DOI MAT KHAU TAI KHOAN ====="
    read -r -p "Nhap ten tai khoan can doi mat khau: " usr
    if id "$usr" &>/dev/null; then
        echo "*** LUU Y: Mat khau phai bao gom chu hoa, chu thuong, so va ky tu dac biet ***"
        passwd "$usr"
        echo "=> Da cap nhat mat khau moi cho tai khoan $usr."
    else
        echo "Loi: Tai khoan '$usr' khong ton tai tren he thong!"
    fi
}

delete_user() {
    echo "===== XOA TAI KHOAN EMAIL ====="
    read -r -p "Nhap ten tai khoan can xoa: " usr
    if id "$usr" &>/dev/null; then
        userdel -r "$usr"
        echo "=> Da xoa tai khoan '$usr' va toan bo hop thu."
    else
        echo "Loi: Tai khoan khong ton tai!"
    fi
}

list_users() {
    echo "===== DANH SACH TAI KHOAN EMAIL HIEN CO ====="
    DOMAIN=$(postconf -h mydomain 2>/dev/null || echo "chuacauhanh.com")
    echo "Cac dia chi Email hop le tren he thong:"
    # Loc cac user do nguoi dung tao ra tren CentOS 7 (UID >= 1000)
    awk -F':' -v dom="$DOMAIN" '{ if ($3 >= 1000 && $3 < 60000) print "- " $1 "@" dom }' /etc/passwd
}

manage_services() {
    echo "===== QUAN LY BẬT/TẮT DICH VU MAIL ====="
    echo "1. Bat he thong (Start)"
    echo "2. Tat he thong (Stop)"
    echo "3. Khoi dong lai he thong (Restart)"
    echo "0. Quay lai menu chinh"
    read -r -p "Chon hanh dong (0-3): " act
    case "$act" in
        1) systemctl start named postfix dovecot httpd; echo "=> Da BAT cac dich vu." ;;
        2) systemctl stop named postfix dovecot httpd; echo "=> Da TAT cac dich vu." ;;
        3) systemctl restart named postfix dovecot httpd; echo "=> Da KHOI DONG LAI cac dich vu." ;;
        0) return ;;
        *) echo "Lua chon khong hop le!" ;;
    esac
}

check_status() {
    echo "===== KIEM TRA TRANG THAI HE THONG ====="
    CURRENT_DOMAIN=$(postconf -h mydomain 2>/dev/null)
    if [ -z "$CURRENT_DOMAIN" ]; then
        echo "[!] He thong chua duoc cau hinh Ten mien."
    else
        echo "=> TEN MIEN (DOMAIN) HIEN TAI: $CURRENT_DOMAIN"
    fi
    echo "------------------------------------------"
    echo "--- Trang thai DNS (Phan giai ten mien) ---"
    systemctl status named | grep Active || echo "   Active: inactive (dead)"
    echo "--- Trang thai Postfix (SMTP - Gui thu) ---"
    systemctl status postfix | grep Active || echo "   Active: inactive (dead)"
    echo "--- Trang thai Dovecot (IMAP/POP3 - Nhan thu) ---"
    systemctl status dovecot | grep Active || echo "   Active: inactive (dead)"
}

while true; do
    clear
    echo "=========================================="
    echo "   AUTOSCRIPT QUAN LY MAIL SERVER (ULTIMATE)"
    echo "       He dieu hanh: CentOS 7"
    echo "=========================================="
    echo "1. Cai dat Core Mail + DNS (Ten mien)"
    echo "2. Cai dat Webmail (SquirrelMail)"
    echo "3. Tao tai khoan Email"
    echo "4. Doi mat khau tai khoan"
    echo "5. Xoa tai khoan Email"
    echo "6. Xem danh sach tai khoan Email"
    echo "7. Bat / Tat / Restart cac dich vu"
    echo "8. Kiem tra trang thai he thong"
    echo "0. Thoat"
    echo "=========================================="
    read -r -p "Nhap lua chon cua ban (0-8): " choice
    case "$choice" in
        1) install_core_mail; pause ;;
        2) install_webmail; pause ;;
        3) manage_user; pause ;;
        4) change_password; pause ;;
        5) delete_user; pause ;;
        6) list_users; pause ;;
        7) manage_services; pause ;;
        8) check_status; pause ;;
        0) echo "Da thoat chuong trinh!"; exit 0 ;;
        *) echo "Lua chon khong hop le!"; pause ;;
    esac
done
