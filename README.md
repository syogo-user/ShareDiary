# ShareDiary

## [目次]  
* 概要  
* 使い方  
* インストール時  
* 特徴  
  
## 概要  
Share=共有  
Diary=日記  
日記を共有するアプリです。  

背景にグラデーションのかかった日記を投稿することができます。  
投稿した日記は自分をフォローしているフォロワーのみ閲覧することができます。  
自分の投稿した日記はMyダイアリータブのカレンダーから確認することができます。  
  
## 使い方  
### ログイン  
1. 初回起動時はニックネーム、メールアドレス、パスワード、を入力後、プライバシーポリシーに同意し、アカウントを作成します  
2. 二回目以降はログイン画面からメールアドレスとパスワードのみの入力でログインできます  
 
### 日記の投稿  
1. Myダイアリータブの＋ボタンから投稿画面に遷移します  
2. 出来事を日記として入力します  
3. 投稿する写真を選択します(写真なしでも可)  
4. 背景色を選択します(デフォルトは黄緑のグラデーション)  
5. 日付を選択します(デフォルトはアプリ起動日)  
6. 投稿ボタンをタップし、投稿します  

### フォローリクエストを申請  
1. 検索タブからフォローを申請したい人のニックネームを入力します  
2. 検索ボタンをタップ後、表示されたユーザに対して、フォロー申請ボタンをタップします  

### 自分とフォローしている人の投稿を閲覧  
1. タイムラインタブより自分とフォローしている人の投稿が閲覧できます  
2. 写真をタップすると拡大表示されます  
3. ハートをタップするといいねをつけられます  
4. コメントボタンをタップし、コメント入力画面からコメントを送信できます  

### プロフィールを編集  
1. プロフィールタブより変更ボタンをタップし、プロフィールを編集します    
2. プロフィール写真の下部にある＋ボタンより写真を変更・追加します  

### 自分の投稿を日付ごとに閲覧  
1. Myダイアリータブのカレンダーにて、投稿した日付の下にマークがついています  
2. マークが付いている日付をタップすると、自分がその日に投稿した内容を閲覧できます  


## インストール時  
ログインにFirebaseを使用しているため、**GoogleService-Info.plist**をXcodeに含めて実行する必要があります  
  
    
## 特徴  
特徴は以下の2点です  
* グラデーション  
 日記の背景色はグラデーションで表示することが可能で、グラデーションの色は投稿ごとに15色からが可能となっています  
* 日付ごとの投稿の閲覧  
　自分が日記を投稿した日にはMyダイアリータブのカレンダーにマークが付きます。マークの付いている日をタップすると  
　その日に投稿した内容だけを確認することができます  






