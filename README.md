# 共通の使い方
## コマンドの実行
学外の場合のみ、コマンドラインの第一引数にMyWasedaのID, 第二引数にMyWasedaのパスワードを入力する。

## 学内、学外の切り替え
メソッドの呼び出しのコメントアウト部分のみ入れ替える。  
外部アクセスでは、ドメインをconfig.app_hostに設定する必要はなし。

## 注意
今のままだとcsvファイルの最初と最後に一つずつダブルクオーテーションが入ってしまいうまくspreadsheetなどで使えない状態なので、最初と最後のダブルクオーテーションは手動で外している。  
gsubでどうにかできないものだろうか。

# kikuzo.rb

## 検索条件の変更
適宜、主に`conditions`の中身や年月日を書き換える。


# yomidas.rb [学外はWIP]

## 検索条件の変更
`fill_in`あたりを適宜書き換える。

## 注意
ヨミダスでは検索画面で地域の選択ができないので、csvファイルを作成してからexcelやgoogle spreadsheetなどで絞り込むと良い。

# maisaku.rb [学外はWIP]

## 検索条件の変更
`select_option`あたりを適宜書き換える。
