# Movieom App

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

## Cài đặt

### Yêu cầu hệ thống
- Flutter SDK >= 3.19.0
- Dart SDK >= 3.0.0
- Thiết bị hoặc máy ảo Android/iOS

### Các bước cài đặt
1. Clone dự án:
   ```bash
   git clone <repository_url>
   ```

2. Cài đặt dependencies:
   ```bash
   flutter pub get
   ```

3. Chạy ứng dụng:
   ```bash
   flutter run
   ```

## Nguồn dữ liệu phim

Ứng dụng sử dụng [phimapi.com](https://kkphim.com/tai-lieu-api) làm nguồn dữ liệu chính, cung cấp:
- Thông tin phim
- Poster và hình ảnh
- Đường dẫn xem phim
- Thể loại và danh mục phim
