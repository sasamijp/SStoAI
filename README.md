# SStoAI

ショートストーリーを人工無能に変換します
スライド: https://www.slideshare.net/sasamijp/ss-31508690

## Installation

`git clone git://github.com/sasamijp/SStoAI.git SStoAI`

`cd SStoAI`

`bundle install`


## Usage

### 作成

./以下にディレクトリを作成し、SSを自動収集して学習データを作る:  

`bundle exec bin/SStoAI new tarou 太郎`

#### 作成途中で失敗した
`bundle exec bin/SStoAI reconvert tarou 太郎`  
今集まってる分だけで学習させます

### 話しかける

話しかける:

`bundle exec bin/SStoAI talk tarou 元気ですか`

### botとして動かす

./tarou/key.rbにbotとして動かしたいアカウントのCK/CSその他もろもろを入れておく  
なんかbundlerでやったらうまくいかんかったもうやだ  
`gem install twitter`  
`gem install tweetstream`

起動:  

`bundle exec bin/SStoAI twitterbot tarou`

### SS自動生成
何人か用意しておく:  
`bundle exec bin/SStoAI new tarou 太郎`  
`bundle exec bin/SStoAI new jirou 次郎`  
`bundle exec bin/SStoAI new saburo 三郎`  

ファイル名、何行文出すか、誰を出演させるかを指定して実行:  
`bundle exec bin/SStoAI generateSS testss.txt 1000 tarou jirou saburou`
  
### 何かあれば@sasamijpまで
