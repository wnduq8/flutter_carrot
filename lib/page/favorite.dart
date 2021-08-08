import 'package:carrot/page/detail.dart';
import 'package:carrot/repository/contents_repository.dart';
import 'package:carrot/utils/data_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyFavoriteContents extends StatefulWidget {
  const MyFavoriteContents({Key? key}) : super(key: key);

  @override
  _MyFavoriteContentsState createState() => _MyFavoriteContentsState();
}

class _MyFavoriteContentsState extends State<MyFavoriteContents> {
  ContentsRepository _ContentsRepository = ContentsRepository();

  _appbarWidget() {
    return AppBar(
      title: Text(
        "관심목록",
        style: TextStyle(
          fontSize: 15,
        ),
      ),
    );
  }

  Future<List<dynamic>> _loadMyFavoriteContentList() async {
    return await _ContentsRepository.loadFavoriteContents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarWidget(),
      body: FutureBuilder(
        future: _loadMyFavoriteContentList(),
        builder: (context, dynamic snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('해당 지역에 데이터가 없습니다.'),
            );
          }

          if (snapshot.hasData) {
            List<dynamic> datas = snapshot.data;
            return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 10),
                itemBuilder: (BuildContext _context, int index) {
                  return InkWell(
                    onTap: () {
                      print(datas[index]);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return DetailContentView(data: datas[index]);
                      }));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Hero(
                            tag: datas[index]["cid"].toString(),
                            child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                child: Image.asset(
                                  datas[index]["image"].toString(),
                                  width: 100,
                                  height: 100,
                                )),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 20),
                              height: 100,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    datas[index]["title"].toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    datas[index]["location"].toString(),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black.withOpacity(0.3)),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    DataUtils.calcStringToWon(
                                        datas[index]["price"].toString()),
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Expanded(
                                    child: Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(bottom: 2),
                                            child: SvgPicture.asset(
                                              "assets/svg/heart_off.svg",
                                              width: 13,
                                              height: 13,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                              datas[index]["likes"].toString()),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext _context, int index) {
                  return Container(
                    height: 1,
                    color: Colors.black.withOpacity(0.4),
                  );
                },
                itemCount: datas.length);
          }

          return Center(
            child: Text('데이터를 받아오는데 오류가 발생했습니다.'),
          );
        },
      ),
    );
  }
}
