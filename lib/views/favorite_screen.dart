import 'package:flutter/material.dart';
import 'package:movieom_app/widgets/Appbarfavorite.dart';
import 'package:movieom_app/widgets/AnimatedPlayButton.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late List<bool> isPlayingList;

  @override
  void initState() {
    super.initState();
    // Khởi tạo tất cả trạng thái ban đầu là false (không phát)
    isPlayingList = List.generate(20, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // Nền đen cho toàn bộ màn hình
      child: Column(
        children: [
          // Thanh AppBar
          const Appbarfavorite(),
          // Hàng chứa 4 nút
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    print('TV-Series được nhấn!');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    elevation: 0,
                    side: const BorderSide(color: Colors.white, width: 2),
                  ),
                  child: const Text('TV-Series'),
                ),
                ElevatedButton(
                  onPressed: () {
                    print('Phim được nhấn!');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    elevation: 0,
                    side: const BorderSide(color: Colors.white, width: 2),
                  ),
                  child: const Text('Phim'),
                ),
                ElevatedButton(
                  onPressed: () {
                    print('Đã xem được nhấn!');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    elevation: 0,
                    side: const BorderSide(color: Colors.white, width: 2),
                  ),
                  child: const Text('Đã xem'),
                ),
                ElevatedButton(
                  onPressed: () {
                    print('Chỉnh sửa được nhấn!');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    elevation: 0,
                    side: const BorderSide(color: Colors.white, width: 2),
                  ),
                  child: const Text('Chỉnh sửa'),
                ),
              ],
            ),
          ),
          // Danh sách phim
          Expanded(
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                String title;
                Color imageColor;

                switch (index % 4) {
                  case 0:
                    title = '1917';
                    imageColor = Colors.grey;
                    break;
                  case 1:
                    title = 'Dune';
                    imageColor = Colors.orange;
                    break;
                  case 2:
                    title = 'Oppenheimer';
                    imageColor = Colors.red;
                    break;
                  case 3:
                    title = 'Perfect Blue';
                    imageColor = Colors.blue;
                    break;
                  default:
                    title = 'Phim $index';
                    imageColor = Colors.grey;
                }

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 200,
                        height: 100,
                        decoration: BoxDecoration(
                          color: imageColor,
                          border: const Border(
                            bottom: BorderSide(color: Colors.blue, width: 2),
                            top: BorderSide(color: Colors.blue, width: 2),
                            left: BorderSide(color: Colors.blue, width: 2),
                            right: BorderSide(color: Colors.blue, width: 2),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedPlayButton(
                        initialIsPlaying: isPlayingList[index],
                        onPressed: () {
                          setState(() {
                            isPlayingList[index] = !isPlayingList[index];
                          });
                          print(isPlayingList[index]
                              ? 'Phát $title'
                              : 'Tạm dừng $title');
                        },
                        playIcon: const Icon(
                          Icons.play_arrow,
                          color: Colors.black,
                          size: 30,
                        ),
                        pauseIcon: const Icon(
                          Icons.pause,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
