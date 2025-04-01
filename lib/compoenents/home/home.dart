import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Center(
      child: Text(
        '홈 화면 내용',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    ),
    Center(
      child: Text(
        '검색 화면 내용',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    ),
    Center(
      child: Text(
        '프로필 화면 내용',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 앱'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_hdr), // 아이콘
            label: '국내 여행', // 라벨
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_repair_service),
            label: '여행 시작',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: '해외 여행',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // FAB를 눌렀을 때 실행될 동작
          print('일정 만들기 버튼 클릭됨!');
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('알림'),
              content: Text('일정 만들기 버튼이 눌렸습니다!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('확인'),
                ),
              ],
            ),
          );
        },
        tooltip: '일정 만들기', // 길게 눌렀을 때 도움말
        icon: const Icon(Icons.add), // 아이콘 지정
        label: const Text('일정 만들기'), // 텍스트 라벨 지정
        // backgroundColor: Colors.blue, // 배경색 (선택 사항)
        // foregroundColor: Colors.white, // 아이콘/텍스트 색상 (선택 사항)
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // 기본 위치
    );
  }
}