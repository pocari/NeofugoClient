# NeofugoClient

[株式会社ネオジニア](http://www.neogenia.co.jp)のサービス「[ネオ富豪](http://neof5.neogenia.co.jp)」にRubyプログラムから参加するのを簡略化するgemです。

## インストール
下記コマンドでgemをインストールします。

    $ gem install neofugo_client

## サンプル

sampleディレクトリに、ただ単純に手札を出すだけのサンプルクライアントを置いています。

## 前提
ネオ富豪はサーバとWebSocketを使用して通信します。
通信内容の仕様は公式サイトの[プログラム仕様](http://neof5.neogenia.co.jp/spec/)を確認してください。

ごく簡単に説明すると
- サーバと接続する
- サーバから各種情報を受信する
- 受信した内容から自分の出す札を決定する
- 決定した札をサーバに送信する

を繰り返します。この内、

- 受信した内容から自分の出す札を決定する

*以外*の部分をこのライブラリがサポートし、何を出すかの部分だけを実装すると
ネオ富豪のクライアントとして動作するようになります。

#### ネオ富豪サーバからのメッセージ概要

サーバからは以下のようなメッセージが送信されます。

```js
{
    "YourNum":0,                                // 受信者の番号（接続順に0から振られます）
    "Kind":"ProcessTurn",                       // ゲーム内で起こったイベントの種類
    "Teban":0,                                  // 現在の手番（プレイヤー番号）
    "IsKakumei":false,                          // 革命中かどうか
    "PlayerInfo":[                              // 対戦中のプレイヤーの情報
        {"Name":"ExampleProgram","HavingCardCount":11,"Ranking":0,"OrderOfFinish":0},
        {"Name":"COM1","HavingCardCount":11,"Ranking":0,"OrderOfFinish":0},
        {"Name":"COM2","HavingCardCount":10,"Ranking":0,"OrderOfFinish":0},
        {"Name":"COM3","HavingCardCount":9,"Ranking":0,"OrderOfFinish":0},
        {"Name":"COM4","HavingCardCount":9,"Ranking":0,"OrderOfFinish":0}],
    "Deck":"D3 H3 D4 S7 H9 D0 SJ CQ SQ DA JK",   // 現在の手札（1枚のカードを2文字で表します）
    "Ba":["S3","D5","S6"],                       // 場に出ているカード
    "Yama":"",                                   // 山にあるカード（流れたカード）
    "History":["2-[S3]","3-[D5]","4-[S6]"]       // ゲームの初手から現在局面までの手の全履歴
}
```

この中で`Kind`の値が`ProcessTurn`の場合、「あなた」の手番が回ってきたことになるので、
このメッセージを受信したときに出す手を決めてサーバに返すとゲームが進行していきます。

#### NeofugoClient概要
NeofugoClientは

- サーバと指定した部屋（練習用の部屋、本番勝負用の部屋などがあります）にアクセスし、メッセージを送受信する部分
- 「あなた」のロジックを実装する部分

に分かれています。
上記で「`Kind`の値が`ProcessTrun`の場合」と書きましたが、そのあたりはライブラリ側が処理するので、
実際に実装するのは`Strategy`クラスを継承したの特定のメソッドのみになります。
`Strategy`クラスを継承すると予めサーバからのメッセージの`Kind`に対応したメソッドが定義されているので、
その中で反応したいメッセージに対応するメソッドのみオーバーライドしてロジックを完成させてください。

#### 最小限のサンプル
基本的には`Kind=PorcessTrun`に反応すれば良いため対応する`on_process_turn`をオーバーライドします。
また選んだカードを送信するには、(これもネオ富豪のメッセージに変換されますが)`put()`で出すカードを指定します。

```ruby
require "neofugo_client"

class MyStrategy < NeofugoClient::Strategy
  def on_process_turn(m)
    cards = your_comprelex_daifugo_logic(m)
    puts(cards)
  end
end
```

引数の`m`は先程載せたメッセージの`json`データをRubyのオブジェクトに変換したものです。

- メッセージ全体は`Message`クラスに該当します
- メッセージ直下にあるプロパティはプロパティー名をスネークケースにしたインスタンス変数として保持しています。例) `YourNum` => @your_num
- `@player_info`は`PlayerInfo`クラスの配列です。
- `@deck`は`Card`クラスの配列です。
- `@ba`は`Card`クラスの配列の配列です。
- `@yama`は`Card`クラスの配列です。
- `@history`は`History`クラスの配列です。

この内、最もロジックに関連する変数は`ba`(今現在場に出ているカード)と`deck`(今あなたが持っているカード)です。
どちらも`Card`クラスが元になっているため、`Card`クラスの概要を下記に記載します。
メッセージ上カードがどう表されるかは公式サイトを参照してください。
このライブラリ上では`Card`クラスは３つのプロパティで表現されます。

```ruby
class Card
  def initialize
    @type #カードの種類を表す文字列です。クラブ: C, ハート: H, ダイヤ: D, スペード: S, ただしJokerの場合JKです。
    @mark #カードに書かれている数字です。A, 2, 3, 4, ... J, Q, K。ただしJokerの場合`nil`です。
    @value #革命時でない場合のカードの強さを表します。3から順に, 0, 1, 2, 3, 4, 5
  end
end
```

この`Card`クラスのインスタンスが`ba`, `deck`を構成しています。
`deck`は単純に今「あなた」が持っている`Card`の配列です。

`ba`は今場に出ているカードの状態です。流れた場合は`[]`配列です。
`ba`については１回に複数枚出すパターンがありえるので、「`Card`の配列の配列」で保持しています。

 - カードが１枚ずつ３人から`c1, c2, c3`の順で出された
 
   `ba = [[c1], [c2], [c3]]`

 - カードが２枚ずつ二人から`(c1-1, c1-2), (c2-1, c2-2)`の順で出された

   `ba = [[c1-1, c1-2], [c2-1, c2-2]]`

という形で取得できます。直接的には最後の手順に対して出せる札が決まるので最後の要素を解析して出す札を決めてください。

#### その他
ネオ富豪のメッセージは、常に最新のメッセージ一つの中に今までのゲームの状態を取得するための情報をすべて保持しているため
上記までで説明していない変数などを利用して有利なロジックを考えてみてください。
例えば、今までに出された札(`history`)と自分が今持っているカード(`deck`)を解析すれば、少なくともこのカードはもう
自分しか持っていないはず、などが推測出来ると思います。

