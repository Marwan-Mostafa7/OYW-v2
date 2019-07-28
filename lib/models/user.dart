class User //implements IConvertible
{
  String id,
      token,
      userEmail,
      pass,
      phone,
      userImgUrl,
      userName,
      userImgPath,
      rating;

  User(
      {this.userEmail,
      this.userName,
      this.phone,
      this.pass,
      this.userImgPath,
      this.userImgUrl,
      this.rating,
      this.id,
      this.token});

  set setUserID(newID) => this.id = newID;
  String get getUserID => this.id;

  set setUserImgURL(imgURL) => this.userImgUrl = imgURL;

  Map<String, dynamic> toJson() => {
        'userId': id,
        'userEmail': userEmail,
        'userName': userName,
        'pass': pass,
        'phone': phone,
        'userImgUrl': userImgUrl,
        'userImg': userImgPath,
        'rating': rating,
        'token': token
      };

  User fromJson(Map<String, dynamic> user) {
    return User(
      id: user['userId'],
      pass: user['pass'],
      phone: user['phone'],
      rating: user['rating'],
      token: user['token'],
      userEmail: user['userEmail'],
      userImgUrl: user['userImgUrl'],
      userName: user['userName'],
    );
  }
}
