# 🚀 CentOS 7 Mail Server Autoscript (Pro Edition)

## ⚠️ Những điều CẦN LƯU Ý khi làm Lab (Troubleshooting)

1. **Lỗi đụng độ Cổng (Port Conflict):** 
   Trước khi chạy Script, hãy chắc chắn máy ảo của bạn chưa cài thủ công các dịch vụ Web (Apache/Nginx) hoặc DNS (BIND) khác đang chạy ngầm, nếu không các cổng 80 và 53 sẽ bị báo lỗi trùng lặp.
2. **Quy tắc đặt Mật khẩu:** 
   Khi tạo User qua phím `3`, hệ điều hành CentOS có thể bắt lỗi nếu mật khẩu quá yếu. Khuyến nghị đặt mật khẩu luôn chứa: **Chữ in hoa, chữ thường, số và ký tự đặc biệt**.
3. **Lưu ý ép DNS trên máy khách (Windows/Máy tính thật):**
   Để máy Windows của bạn có thể truy cập `http://ten-mien-cua-ban/webmail`, bạn **BẮT BUỘC** phải đổi địa chỉ **Preferred DNS server (IPv4)** trên card mạng của máy Windows thành địa chỉ IP của máy CentOS.
4. **Lỗi hộp thư bị loạn khi Test:**
   SquirrelMail lưu bộ nhớ đệm (Cookie) trên trình duyệt. **Tuyệt đối không** dùng cùng 1 cửa sổ trình duyệt để đăng nhập luân phiên 2 tài khoản (sẽ gây kẹt luồng thư). Hãy dùng cửa sổ Ẩn danh (Incognito/InPrivate) để test cho tài khoản thứ 2.

---

Đây là kịch bản (Bash Script) tự động hóa toàn bộ quá trình cài đặt, cấu hình và quản lý hệ thống Mail Server nội bộ trên hệ điều hành **CentOS 7**. Kịch bản được tối ưu hóa cho các bài thực hành Lab Mạng máy tính, giúp tiết kiệm thời gian gõ lệnh thủ công và hạn chế tối đa các lỗi cấu hình sai sót.

## ✨ Tính năng nổi bật

### 1. Tự động hóa Hạ tầng Lõi (Core Infrastructure)
*   Tự động gỡ bỏ `sendmail` (chống xung đột cổng), cài đặt **Postfix** (SMTP) và **Dovecot** (POP3/IMAP).
*   Tự động cấu hình dịch vụ phân giải tên miền **DNS Server (BIND)**, cho phép truy cập Webmail trực tiếp bằng tên miền ảo thay vì dùng địa chỉ IP.
*   Tự động xử lý bảo mật: Mở khóa các cổng Tường lửa cần thiết (21, 25, 53, 80, 110, 143) và cấu hình nới lỏng SELinux.

### 2. Tự động hóa Webmail
*   Cài đặt **Apache (httpd)** và cấu hình giao diện **SquirrelMail** phiên bản chuẩn.
*   Tự động ép luồng tên miền vào file cấu hình của PHP mà không cần thao tác bằng tay trên giao diện `conf.pl`.

### 3. Tính năng Quản trị & Sáng tạo (Pro Features)
*   **Menu tương tác (Interactive UI):** Quản lý hệ thống qua bảng menu chọn phím (0-8) ngay trên Terminal.
*   **Auto-Welcome Email:** Tự động gửi thư chào mừng vào hộp thư của người dùng ngay khi tài khoản được tạo mới.
*   **Quản lý Tài khoản trọn gói:** Thêm mới, Xóa, Đổi mật khẩu tài khoản nhanh chóng.
*   **Liệt kê User thông minh:** Quét hệ thống và chỉ hiển thị những địa chỉ Email hợp lệ do người dùng tạo.
*   **Kiểm tra trạng thái (Status Check):** Theo dõi tức thời trạng thái "Sống/Chết" của các dịch vụ DNS, Postfix và Dovecot.

---

## 🛠 Yêu cầu hệ thống (Prerequisites)
*   Quyền thực thi: Bắt buộc đăng nhập bằng quyền **`root`** (dùng lệnh `su -`).
*   Máy chủ phải có kết nối Internet trong lần chạy đầu tiên để tải các gói cài đặt (`yum`).

---

## 🚀 Hướng dẫn cài đặt và sử dụng

Chạy lần lượt các lệnh sau trên màn hình Terminal của CentOS 7:

```bash
# 1. Tải công cụ wget (nếu chưa có)
yum install -y wget

# 2. Tải kịch bản từ GitHub về máy ảo (Thay link raw bên dưới bằng link thực tế của bạn)
wget [https://github.com/quachtuanhao2006-cell/autoscript-mail-centos/blob/main/mail.sh](https://github.com/quachtuanhao2006-cell/autoscript-mail-centos/blob/main/mail.sh)

# 3. Cấp quyền thực thi cho file script
chmod +x mail.sh

# 4. Khởi chạy Menu Quản trị
./mail.sh
