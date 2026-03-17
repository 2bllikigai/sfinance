# 💰 SFINANCE - Smart Personal Finance Manager

**sfinance** là ứng dụng quản lý tài chính cá nhân toàn diện được phát triển bằng framework **Flutter**. Đây là bài tập lớn môn học Lập trình Mobile, tập trung vào trải nghiệm người dùng mượt mà, tính toán chính xác và bảo mật dữ liệu cục bộ.

---

## 🌟 Tính năng chính 

### 🔒 Bảo mật tuyệt đối
* **Màn hình PIN Lock:** Bảo vệ dữ liệu tài chính bằng mã PIN 4 số ngay khi khởi động.

### 📊 Dashboard thông minh
* **Tổng hợp tự động:** Hiển thị Số dư hiện tại (Balance), Tổng thu nhập (Income) và Tổng chi tiêu (Expense) bằng các biểu đồ màu sắc trực quan.
* **Logic thời gian thực:** Dữ liệu tự động nhảy số ngay khi có giao dịch mới được thêm hoặc xóa.

### 📝 Quản lý giao dịch (Full CRUD)
* **Thêm mới:** Form nhập liệu chuyên nghiệp với DatePicker và định dạng tiền tệ VNĐ.
* **Kiểm tra dữ liệu (Validation):** Ngăn chặn lỗi nhập liệu trống hoặc sai định dạng số tiền.
* **Chỉnh sửa & Xóa:** Linh hoạt cập nhật thông tin hoặc xóa giao dịch với hộp thoại xác nhận an toàn.

### 🌓 Trải nghiệm người dùng (UX/UI)
* **Dark Mode:** Hỗ trợ giao diện sáng/tối tùy chọn, tự động lưu lại cấu hình theo sở thích người dùng.
* **Thiết kế hiện đại:** Sử dụng ngôn ngữ Material Design 3 với các thẻ bo góc và hiệu ứng Gradient.

---

## 🛠 Công nghệ sử dụng 

* **Framework:** Flutter (Kênh Stable)
* **State Management:** `Provider` - Quản lý trạng thái ứng dụng tách biệt với UI.
* **Database:** `SQLite` (thông qua `sqflite` & `sqflite_common_ffi`) - Lưu trữ dữ liệu an toàn trên bộ nhớ máy Mac.
* **Local Storage:** `shared_preferences` - Lưu trữ mã PIN và cấu hình giao diện.
* **Formatting:** `intl` - Xử lý ngày tháng và tiền tệ chuẩn Việt Nam.

---

## 📂 Cấu trúc dự án

```text
lib/
├── main.dart                  # Khởi tạo app & cấu hình Provider
├── models/
│   └── transaction_model.dart # Cấu trúc dữ liệu giao dịch
├── data/
│   └── database_helper.dart   # Quản lý SQLite (Kết nối & Truy vấn)
├── providers/
│   ├── transaction_provider.dart # Logic tính toán Thu/Chi
│   ├── theme_provider.dart       # Quản lý Sáng/Tối
│   └── pin_provider.dart         # Xử lý bảo mật mã PIN
└── screens/
    ├── pin_screen.dart        # Màn hình khóa PIN
    ├── home_screen.dart       # Màn hình chính & Dashboard
    ├── add_edit_screen.dart   # Form nhập liệu
    ├── detail_screen.dart     # Xem chi tiết & Xóa
    └── settings_screen.dart   # Cài đặt giao diện
