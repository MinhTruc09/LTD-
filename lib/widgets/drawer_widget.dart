import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(),
          _buildItem(
            icon: CupertinoIcons.home,
            title: 'Home',
            onTap: () => Navigator.pop(context),
          ),
          _buildItem(
            icon: CupertinoIcons.bell,
            title: 'Notifications',
            onTap: () => Navigator.pop(context),
          ),
          _buildItem(
            icon: CupertinoIcons.person,
            title: 'Profile',
            onTap: () => Navigator.pop(context),
          ),
          _buildItem(
            icon: Icons.settings,
            title: 'Setting',
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const DrawerHeader(
      decoration: BoxDecoration(color: Color(0xff1D1E22)),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
                'https://media.istockphoto.com/id/1399611777/photo/portrait-of-a-smiling-little-brown-haired-boy-looking-at-the-camera-happy-kid-with-good.jpg?s=612x612&w=0&k=20&c=qZ63xODwrnc81wKK0dwc3tOEf2lghkQQKmotbF11q7Q='),
            radius: 40,
          ),
          SizedBox(height: 20),
          Text(
            'Mahdi Nazmi',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String title,
    required GestureTapCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
      minLeadingWidth: 5,
    );
  }
}