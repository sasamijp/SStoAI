# SStoAI

ショートストーリーを人工無能に変換します

## Installation

$ git clone git://github.com/sasamijp/SStoAI.git SStoAI

$ cd SStoAI

$ bundle install


## Usage

###作成

人工無能をhome以下に勝手に作る:

$ bundle exec bin/SStoAI new harukabot 春香

〜対象キャラが出てくるSSをただひたすら集める〜

$ cd ~/harukabot/libs/ss.txt

ss.txtに本文を突っ込む(2chの名前欄などはあっても大丈夫):

$ cd ~/harukabot

SS内で使用されるキャラの名前を指定してconvert:

$ ruby cli.rb convert 春香

/libs/data.txtにデータが書き込まれてれば成功

SS収集、学習を全自動で(アイマスキャラのみ対応):

$ bundle exec bin/SStoAi new harukabot 春香 --autocollection

###話しかける

ホームに移動:

$ cd ~

作ったAIのフォルダへ:

$ cd harukabot

gemいれる:

$ bundle install

話しかける:

$ ruby cli.rb talk 元気ですか

###botとして動かす

./libs/key.rbにbotとして動かしたいアカウントのCK/CSその他もろもろを入れておく

$ ruby cli.rb twitterbot


###何かあれば@sasamijpまで
