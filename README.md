# 🚀 CentOS 7 Mail Server Autoscript

## ⚠️ Những điều CẦN LƯU Ý khi sử dụng (Troubleshooting)

1. **Quy tắc đặt Mật khẩu:** 
   Khi tạo User qua phím `3`, hệ điều hành CentOS có thể bắt lỗi nếu mật khẩu quá yếu. Khuyến nghị đặt mật khẩu luôn chứa: **Chữ in hoa, chữ thường, số và ký tự đặc biệt**.
2. **Lưu ý ép cài đặt DNS trên máy khách:**
   Để máy khách của bạn có thể truy cập bạn cần đổi địa chỉ **Preferred DNS server (IPv4)** trên card mạng của máy khách thành địa chỉ IP của máy CentOS.
3. **Lỗi hộp thư bị loạn khi Test:**
   Khuyến nghị ko nên dùng 2 tab của cùng 1 trình duyệt để đăng nhập 2 tài khoản có thể gây lỗi.

---

Đây là kịch bản (Bash Script) tự động hóa toàn bộ quá trình cài đặt, cấu hình và quản lý hệ thống Mail Server nội bộ trên hệ điều hành **CentOS 7**. Kịch bản được tối ưu hóa giúp tiết kiệm thời gian gõ lệnh thủ công.

## ✨ Tính năng nổi bật

### 1. Tự động hóa Hạ tầng Lõi (Core Infrastructure)
*   Tự động gỡ bỏ `sendmail` (chống xung đột cổng), cài đặt **Postfix** (SMTP) và **Dovecot** (POP3/IMAP).
*   Tự động cấu hình dịch vụ phân giải tên miền **DNS Server (BIND)**
*   Tự động xử lý bảo mật: Mở khóa các cổng Tường lửa cần thiết (21, 25, 53, 80, 110, 143) và cấu hình nới lỏng SELinux.

### 2. Tự động hóa Webmail
*   Cài đặt **Apache (httpd)** và cấu hình giao diện **SquirrelMail**.
*   Tự động ép luồng tên miền vào file cấu hình của PHP.

### 3. Tính năng Quản trị & Sáng tạo (Pro Features)
*   **Menu tương tác:** Quản lý hệ thống qua bảng menu chọn phím (0-8) ngay trên Terminal.
*   **Quản lý Tài khoản:** Thêm mới, Xóa, Đổi mật khẩu, xem danh sách tài khoản nhanh chóng.
*   **Kiểm tra trạng thái (Status Check):** Theo dõi tức thời trạng thái "Bật/Tắt" của các dịch vụ DNS, Postfix và Dovecot.
## 4. Nếu bản Centos của bạn không còn hỗ gói yum thì phần script đã giúp bạn chuyển hướng sang Vault Centos và có thể dùng lệnh yum.
---

## 🛠 Yêu cầu hệ thống (Prerequisites)
*   Quyền thực thi: Bắt buộc đăng nhập bằng quyền **`root`** (dùng lệnh `su -`).
*   Máy chủ phải có kết nối Internet trong lần chạy đầu tiên để tải các gói cài đặt (`yum`).

---

## 🚀 Hướng dẫn cài đặt và sử dụng


```bash
# 1. Tải công cụ wget (nếu chưa có)
yum install -y wget

# 2. Tải kịch bản từ GitHub về máy ảo
wget https://raw.githubusercontent.com/quachtuanhao2006-cell/autoscript-mail-centos/main/mail.sh

# 3. Cấp quyền thực thi cho file script
chmod +x mail.sh

# 4. Khởi chạy Menu Quản trị
./mail.sh
