import 'package:carousel_slider/carousel_slider.dart';
import 'package:carrot/custom_widget/manor_temperature_widget.dart';
import 'package:carrot/repository/contents_repository.dart';
import 'package:carrot/utils/data_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DetailContentView extends StatefulWidget {
  Map<String, dynamic>? data;
  DetailContentView({Key? key, this.data}) : super(key: key);

  @override
  _DetailContentViewState createState() => _DetailContentViewState();
}

class _DetailContentViewState extends State<DetailContentView>
    with SingleTickerProviderStateMixin {
  List<Map<String, String>> imgList = [];
  int _current = 0;
  double scollPositionToAplpha = 0;
  ScrollController _scrollController = ScrollController();
  AnimationController? _animationController;
  Animation? _colorTween;
  bool isMyFavoriteContent = false;
  ContentsRepository contentsRepository = ContentsRepository();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    _colorTween = ColorTween(begin: Colors.white, end: Colors.black)
        .animate(_animationController!);

    _scrollController.addListener(() {
      setState(() {
        if (_scrollController.offset > 255) {
          scollPositionToAplpha = 255;
        } else if (_scrollController.offset > 0) {
          scollPositionToAplpha = _scrollController.offset;
        } else {
          scollPositionToAplpha = 0;
        }
        _animationController!.value = scollPositionToAplpha / 255;
      });
    });

    _loadMyFavoriteContentState();
  }

  _loadMyFavoriteContentState() async {
    bool ck = await contentsRepository
        .isMyFavoriteContents(widget.data!["cid"].toString());

    setState(() {
      isMyFavoriteContent = ck;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    imgList = [
      {"id": "0", "url": widget.data!["image"].toString()},
      {"id": "1", "url": widget.data!["image"].toString()},
      {"id": "2", "url": widget.data!["image"].toString()},
      {"id": "3", "url": widget.data!["image"].toString()},
      {"id": "4", "url": widget.data!["image"].toString()},
    ];
  }

  _makeIcon(IconData icon) {
    return AnimatedBuilder(
        animation: _colorTween!,
        builder: (context, child) => Icon(
              icon,
              color: _colorTween!.value,
            ));
  }

  _appbarWidget() {
    return AppBar(
      backgroundColor: Colors.white.withAlpha(scollPositionToAplpha.toInt()),
      elevation: 0,
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: _makeIcon(Icons.arrow_back)),
      actions: [
        IconButton(onPressed: () {}, icon: _makeIcon(Icons.share)),
        IconButton(onPressed: () {}, icon: _makeIcon(Icons.more_vert)),
      ],
    );
  }

  _bottomBarWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      width: MediaQuery.of(context).size.width,
      height: 55,
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              if (isMyFavoriteContent) {
                await contentsRepository
                    .deleteMyFavoriteContent(widget.data!["cid"].toString());
              } else {
                await contentsRepository.addMyFavoriteContent(widget.data);
              }

              setState(() {
                isMyFavoriteContent = !isMyFavoriteContent;
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: Duration(seconds: 1),
                  content: Text(isMyFavoriteContent
                      ? "관심목록에 추가됐습니다."
                      : "관심목록에 제거됐습니다.")));
            },
            child: SvgPicture.asset(
              isMyFavoriteContent
                  ? "assets/svg/heart_on.svg"
                  : "assets/svg/heart_off.svg",
              width: 25,
              height: 25,
              color: Color(0xfff08f4f),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 15, right: 10),
            width: 1,
            height: 40,
            color: Colors.grey.withOpacity(0.3),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                Text(
                  DataUtils.calcStringToWon(widget.data!["price"].toString()),
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Text(
                  '가격제안 불가',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                )
              ],
            ),
          ),
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Color(0xfff08f4f),
                ),
                child: Text(
                  '채팅으로 거래하기',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ))
        ],
      ),
    );
  }

  _makeSliderImage() {
    return Container(
      child: Stack(
        children: [
          Hero(
            tag: widget.data!["cid"].toString(),
            child: CarouselSlider(
              options: CarouselOptions(
                height: MediaQuery.of(context).size.width,
                enableInfiniteScroll: false,
                viewportFraction: 1,
                initialPage: 0,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
              items: imgList.map((map) {
                return Image.asset(
                  map["url"].toString(),
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.fill,
                );
              }).toList(),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: imgList.map((map) {
                  return Container(
                    width: 10.0,
                    height: 10.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _current == int.parse(map["id"].toString())
                            ? Color.fromRGBO(0, 0, 0, 0.9)
                            : Color.fromRGBO(0, 0, 0, 0.4)),
                  );
                }).toList()),
          )
        ],
      ),
    );
  }

  _sellerSimpleInfo() {
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: Row(
        children: [
          // ClipRRect(
          //   borderRadius: BorderRadius.circular(50),
          //   child: Container(
          //     width: 50,
          //     height: 50,
          //     child: Image.asset("assets/images/user.png"),
          //   ),
          // ) 하단 이미지와 동일
          CircleAvatar(
            radius: 25,
            backgroundImage: Image.asset("assets/images/user.png").image,
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "박주엽",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text("서울"),
            ],
          ),
          Expanded(
            child: ManorTemperature(
              manorTemp: 37.5,
            ),
          )
        ],
      ),
    );
  }

  _line() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      height: 1,
      color: Colors.grey.withOpacity(0.3),
    );
  }

  _contentDetail() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 20,
          ),
          Text(
            widget.data!["title"].toString(),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            '디지털/가전 22시간 전',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            '선물받은 새상품이고 \n상품 꺼내보기만 했습니다.\n거래는 직거래만 합니다.',
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            '채팅 3 , 관심 17, 조회 295',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  _otherSellContent() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "판매자님의 판매 상품",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Text(
            "모두보기",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appbarWidget(),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverList(
              delegate: SliverChildListDelegate([
            _makeSliderImage(),
            _sellerSimpleInfo(),
            _line(),
            _contentDetail(),
            _line(),
            _otherSellContent(),
          ])),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10),
              delegate: SliverChildListDelegate(List.generate(20, (index) {
                return Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          color: Colors.grey,
                          height: 120,
                        ),
                      ),
                      Text(
                        '상품 제목',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        '금액',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList()),
            ),
          )
        ],
      ),
      bottomNavigationBar: _bottomBarWidget(),
    );
  }
}
