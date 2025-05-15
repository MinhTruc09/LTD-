# Movieom App

<p align="center">
  <img src="assets/images/logo.png" alt="Movieom Logo" width="200"/>
</p>

Ứng dụng xem phim dành cho thiết bị di động, được phát triển với Flutter.

## Giới thiệu

Movieom là ứng dụng xem phim trực tuyến với giao diện thân thiện, cho phép người dùng:
- Khám phá phim mới cập nhật
- Tìm kiếm phim theo tên, thể loại
- Xem thông tin chi tiết về phim
- Lưu phim yêu thích
- Đăng ký và đăng nhập tài khoản
- Xem phim trực tuyến với trình phát video tích hợp

## Công nghệ sử dụng

- **Flutter & Dart**: Framework và ngôn ngữ chính để xây dựng ứng dụng
- **Firebase**: Xác thực, cơ sở dữ liệu
  - Firebase Authentication: Quản lý đăng ký/đăng nhập
  - Cloud Firestore: Lưu trữ dữ liệu người dùng và phim yêu thích
- **RESTful API**: Kết nối với phimapi.com để lấy dữ liệu phim
- **Video Player & Chewie**: Các plugin phát video tích hợp
- **Shared Preferences**: Lưu trữ cục bộ cho dữ liệu người dùng

## Cấu trúc dự án

- `lib/Entity`: Các model dữ liệu (MovieModel, ApiMovie, UserModel...)
- `lib/views`: Các màn hình UI (Home, Search, Detail, Player...)
- `lib/services`: Các dịch vụ API và dữ liệu (Movie API, Authentication...)
- `lib/controllers`: Logic điều khiển ứng dụng
- `lib/widgets`: Các widget tái sử dụng
- `lib/routes`: Định tuyến ứng dụng

## Tính năng chính

1. **Trang chủ**: Hiển thị phim mới cập nhật, phim phổ biến
2. **Tìm kiếm**: Tìm kiếm phim theo tên, lọc theo thể loại
3. **Chi tiết phim**: Hiển thị thông tin phim, diễn viên, đánh giá
4. **Xem phim**: Trình phát video tích hợp với đầy đủ điều khiển
5. **Yêu thích**: Lưu và quản lý danh sách phim yêu thích
6. **Hồ sơ người dùng**: Quản lý tài khoản, xem lịch sử

## Giao diện ứng dụng

Movieom có giao diện người dùng hiện đại và trực quan:
- Theme tối ưu cho trải nghiệm xem phim
- Hiệu ứng chuyển động mượt mà
- Bố cục thông minh, dễ điều hướng
- Tối ưu hóa cho nhiều kích thước màn hình

## Cài đặt

### Yêu cầu hệ thống
- Flutter SDK >= 3.19.0
- Dart SDK >= 3.0.0
- Thiết bị hoặc máy ảo Android/iOS

### Các bước cài đặt
1. Clone dự án:
   ```bash
   git clone https://github.com/MinhTruc09/LTD-.git
   ```

2. Cài đặt dependencies:
   ```bash
   flutter pub get
   ```

3. Chạy ứng dụng:
   ```bash
   flutter run
   ```

## Kiến trúc ứng dụng

Movieom được xây dựng với kiến trúc rõ ràng và module hóa cao:

1. **Điểm khởi đầu**: `lib/main.dart` - Khởi tạo Firebase và thiết lập theme tối cho ứng dụng
2. **Định tuyến**: `lib/routes/app_routes.dart` - Quản lý điều hướng giữa các màn hình
3. **Giao diện người dùng**: Dark Theme được tối ưu hóa cho việc xem phim
4. **Quản lý Trạng thái**: Sử dụng kết hợp StatefulWidget và dịch vụ Firebase
5. **Xác thực**: Firebase Authentication đảm bảo quản lý người dùng an toàn
6. **Lưu trữ dữ liệu**: Cloud Firestore lưu thông tin người dùng và danh sách yêu thích

### Mô hình dữ liệu

Ứng dụng sử dụng các mô hình dữ liệu chính:
- `MovieModel`: Biểu diễn thông tin phim từ API
- `UserModel`: Quản lý thông tin người dùng
- `ApiMovie`: Xử lý dữ liệu thô từ API phim

## Nguồn dữ liệu phim
Ứng dụng sử dụng [phimapi.com](https://kkphim.com/tai-lieu-api) làm nguồn dữ liệu chính, cung cấp:
- Thông tin phim
- Poster và hình ảnh
- Đường dẫn xem phim
- Thể loại và danh mục phim

## Đóng góp

Chúng tôi rất hoan nghênh sự đóng góp từ cộng đồng:
1. Fork dự án
2. Tạo nhánh feature: `git checkout -b feature/amazing-feature`
3. Commit thay đổi: `git commit -m 'Add some amazing feature'`
4. Push lên nhánh: `git push origin feature/amazing-feature`
5. Mở Pull Request

## Liên hệ

Nếu bạn có bất kỳ câu hỏi hoặc đề xuất nào, vui lòng liên hệ với nhóm phát triển qua email hoặc mở issue trong repository.

## QR Code

<p align="center">
  <img src="assets/images/logo.png" alt="Movieom Logo" width="200"/>
</p>

**Lưu ý:** Bạn có thể quét mã QR code để tìm hiểu thêm về ứng dụng hoặc tải về. Mã QR code được cung cấp trong tài liệu dự án.

## Giấy phép

Dự án này được phân phối dưới Giấy phép MIT. Xem tệp `LICENSE` để biết thêm thông tin.

---

&copy; 2023 Movieom Team. All rights reserved.
