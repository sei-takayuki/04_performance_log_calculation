sar,iostatの結果のうち、必要な時刻範囲で必要な項目のみ抽出し、csvファイル形式で出力する
配列、ハッシュを用いるのでperlを使用する


使用方法  cpuio.pl starttime1[HH:MM:SS] endtime1[HH:MM:SS] starttime2{HH:MM:SS] endtime2[HH:MM:SS]



出力
count %user_avg  count2 avgqu_sz_avg %util_avg


パラメータ指定
開始時刻：引数１
終了時刻：引数２
開始時刻：引数３
終了時刻：引数４
sar -u 結果のパス
iostatの結果のパス










