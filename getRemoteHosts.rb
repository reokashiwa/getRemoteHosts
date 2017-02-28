# coding: utf-8
def getRemoteHost(mail)
  # ヘッダと本分の境には\r\n\r\nがあるので、これで分離。
  headers = mail.read.split("\r\n\r\n")[0]
  
  # 複数行にまたがるフィールドを一行にする。(RFC2822 2.2.3)
  ordered_headers = headers.gsub(/\r\n\s/, " ")

  # 1フィールドを1要素とする配列にする。
  fields = ordered_headers.split("\r\n")

  # Received:フィールドだけを抽出する。
  received_fields = Array.new
  fields.each{|field|
    received_fields.push(field) if field =~ /^Received:/
  }
  # 最後のReceived:フィールド
  last = received_fields[received_fields.length - 1]
  
  # IPv4アドレスを抽出
  octet_regexp = "(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]\\d|\\d)"
  addresses = last.scan(%r|((#{octet_regexp}\.){3}#{octet_regexp})|)

  # rubyのscanの仕様上、こうやって取り出す。
  addresses.each{|address|
    printf("%s\t", address[0])
  }
  printf("\n")
  
end

# 標準入出力からでも引数でファイルを指定しても処理できます。
if File.pipe?(STDIN) then
  getRemoteHost(STDIN)
elsif
  getRemoteHost(File.open(ARGV[0]))
end

# usage:
# cat hoge.txt|ruby getRemoteHost.rb あるいは
# ruby getRemoteHost.rb hoge.txt
