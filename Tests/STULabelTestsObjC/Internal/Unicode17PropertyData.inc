// Unicode 17.0.0 property records from https://www.unicode.org/Public/17.0.0/ucd/
// © 2025 Unicode®, Inc. Unicode and the Unicode Logo are registered trademarks.
// Terms of use: https://www.unicode.org/terms_of_use.html
// Source records are copied without descriptive comments; @missing defaults are retained.
// This test oracle is independent of STULabel's packed property tables.

// DerivedBidiClass.txt
static const char unicode17BidiClass[] = R"UCD(
# @missing: 0000..10FFFF; Left_To_Right
# @missing: 0590..05FF; Right_To_Left
# @missing: 0600..07BF; Arabic_Letter
# @missing: 07C0..085F; Right_To_Left
# @missing: 0860..08FF; Arabic_Letter
# @missing: 20A0..20CF; European_Terminator
# @missing: FB1D..FB4F; Right_To_Left
# @missing: FB50..FDCF; Arabic_Letter
# @missing: FDF0..FDFF; Arabic_Letter
# @missing: FE70..FEFF; Arabic_Letter
# @missing: 10800..10CFF; Right_To_Left
# @missing: 10D00..10D3F; Arabic_Letter
# @missing: 10D40..10EBF; Right_To_Left
# @missing: 10EC0..10EFF; Arabic_Letter
# @missing: 10F00..10F2F; Right_To_Left
# @missing: 10F30..10F6F; Arabic_Letter
# @missing: 10F70..10FFF; Right_To_Left
# @missing: 1E800..1EC6F; Right_To_Left
# @missing: 1EC70..1ECBF; Arabic_Letter
# @missing: 1ECC0..1ECFF; Right_To_Left
# @missing: 1ED00..1ED4F; Arabic_Letter
# @missing: 1ED50..1EDFF; Right_To_Left
# @missing: 1EE00..1EEFF; Arabic_Letter
# @missing: 1EF00..1EFFF; Right_To_Left
0041..005A    ; L
0061..007A    ; L
00AA          ; L
00B5          ; L
00BA          ; L
00C0..00D6    ; L
00D8..00F6    ; L
00F8..01BA    ; L
01BB          ; L
01BC..01BF    ; L
01C0..01C3    ; L
01C4..0293    ; L
0294..0295    ; L
0296..02AF    ; L
02B0..02B8    ; L
02BB..02C1    ; L
02D0..02D1    ; L
02E0..02E4    ; L
02EE          ; L
0370..0373    ; L
0376..0377    ; L
037A          ; L
037B..037D    ; L
037F          ; L
0386          ; L
0388..038A    ; L
038C          ; L
038E..03A1    ; L
03A3..03F5    ; L
03F7..0481    ; L
0482          ; L
048A..052F    ; L
0531..0556    ; L
0559          ; L
055A..055F    ; L
0560..0588    ; L
0589          ; L
0903          ; L
0904..0939    ; L
093B          ; L
093D          ; L
093E..0940    ; L
0949..094C    ; L
094E..094F    ; L
0950          ; L
0958..0961    ; L
0964..0965    ; L
0966..096F    ; L
0970          ; L
0971          ; L
0972..0980    ; L
0982..0983    ; L
0985..098C    ; L
098F..0990    ; L
0993..09A8    ; L
09AA..09B0    ; L
09B2          ; L
09B6..09B9    ; L
09BD          ; L
09BE..09C0    ; L
09C7..09C8    ; L
09CB..09CC    ; L
09CE          ; L
09D7          ; L
09DC..09DD    ; L
09DF..09E1    ; L
09E6..09EF    ; L
09F0..09F1    ; L
09F4..09F9    ; L
09FA          ; L
09FC          ; L
09FD          ; L
0A03          ; L
0A05..0A0A    ; L
0A0F..0A10    ; L
0A13..0A28    ; L
0A2A..0A30    ; L
0A32..0A33    ; L
0A35..0A36    ; L
0A38..0A39    ; L
0A3E..0A40    ; L
0A59..0A5C    ; L
0A5E          ; L
0A66..0A6F    ; L
0A72..0A74    ; L
0A76          ; L
0A83          ; L
0A85..0A8D    ; L
0A8F..0A91    ; L
0A93..0AA8    ; L
0AAA..0AB0    ; L
0AB2..0AB3    ; L
0AB5..0AB9    ; L
0ABD          ; L
0ABE..0AC0    ; L
0AC9          ; L
0ACB..0ACC    ; L
0AD0          ; L
0AE0..0AE1    ; L
0AE6..0AEF    ; L
0AF0          ; L
0AF9          ; L
0B02..0B03    ; L
0B05..0B0C    ; L
0B0F..0B10    ; L
0B13..0B28    ; L
0B2A..0B30    ; L
0B32..0B33    ; L
0B35..0B39    ; L
0B3D          ; L
0B3E          ; L
0B40          ; L
0B47..0B48    ; L
0B4B..0B4C    ; L
0B57          ; L
0B5C..0B5D    ; L
0B5F..0B61    ; L
0B66..0B6F    ; L
0B70          ; L
0B71          ; L
0B72..0B77    ; L
0B83          ; L
0B85..0B8A    ; L
0B8E..0B90    ; L
0B92..0B95    ; L
0B99..0B9A    ; L
0B9C          ; L
0B9E..0B9F    ; L
0BA3..0BA4    ; L
0BA8..0BAA    ; L
0BAE..0BB9    ; L
0BBE..0BBF    ; L
0BC1..0BC2    ; L
0BC6..0BC8    ; L
0BCA..0BCC    ; L
0BD0          ; L
0BD7          ; L
0BE6..0BEF    ; L
0BF0..0BF2    ; L
0C01..0C03    ; L
0C05..0C0C    ; L
0C0E..0C10    ; L
0C12..0C28    ; L
0C2A..0C39    ; L
0C3D          ; L
0C41..0C44    ; L
0C58..0C5A    ; L
0C5C..0C5D    ; L
0C60..0C61    ; L
0C66..0C6F    ; L
0C77          ; L
0C7F          ; L
0C80          ; L
0C82..0C83    ; L
0C84          ; L
0C85..0C8C    ; L
0C8E..0C90    ; L
0C92..0CA8    ; L
0CAA..0CB3    ; L
0CB5..0CB9    ; L
0CBD          ; L
0CBE          ; L
0CBF          ; L
0CC0..0CC4    ; L
0CC6          ; L
0CC7..0CC8    ; L
0CCA..0CCB    ; L
0CD5..0CD6    ; L
0CDC..0CDE    ; L
0CE0..0CE1    ; L
0CE6..0CEF    ; L
0CF1..0CF2    ; L
0CF3          ; L
0D02..0D03    ; L
0D04..0D0C    ; L
0D0E..0D10    ; L
0D12..0D3A    ; L
0D3D          ; L
0D3E..0D40    ; L
0D46..0D48    ; L
0D4A..0D4C    ; L
0D4E          ; L
0D4F          ; L
0D54..0D56    ; L
0D57          ; L
0D58..0D5E    ; L
0D5F..0D61    ; L
0D66..0D6F    ; L
0D70..0D78    ; L
0D79          ; L
0D7A..0D7F    ; L
0D82..0D83    ; L
0D85..0D96    ; L
0D9A..0DB1    ; L
0DB3..0DBB    ; L
0DBD          ; L
0DC0..0DC6    ; L
0DCF..0DD1    ; L
0DD8..0DDF    ; L
0DE6..0DEF    ; L
0DF2..0DF3    ; L
0DF4          ; L
0E01..0E30    ; L
0E32..0E33    ; L
0E40..0E45    ; L
0E46          ; L
0E4F          ; L
0E50..0E59    ; L
0E5A..0E5B    ; L
0E81..0E82    ; L
0E84          ; L
0E86..0E8A    ; L
0E8C..0EA3    ; L
0EA5          ; L
0EA7..0EB0    ; L
0EB2..0EB3    ; L
0EBD          ; L
0EC0..0EC4    ; L
0EC6          ; L
0ED0..0ED9    ; L
0EDC..0EDF    ; L
0F00          ; L
0F01..0F03    ; L
0F04..0F12    ; L
0F13          ; L
0F14          ; L
0F15..0F17    ; L
0F1A..0F1F    ; L
0F20..0F29    ; L
0F2A..0F33    ; L
0F34          ; L
0F36          ; L
0F38          ; L
0F3E..0F3F    ; L
0F40..0F47    ; L
0F49..0F6C    ; L
0F7F          ; L
0F85          ; L
0F88..0F8C    ; L
0FBE..0FC5    ; L
0FC7..0FCC    ; L
0FCE..0FCF    ; L
0FD0..0FD4    ; L
0FD5..0FD8    ; L
0FD9..0FDA    ; L
1000..102A    ; L
102B..102C    ; L
1031          ; L
1038          ; L
103B..103C    ; L
103F          ; L
1040..1049    ; L
104A..104F    ; L
1050..1055    ; L
1056..1057    ; L
105A..105D    ; L
1061          ; L
1062..1064    ; L
1065..1066    ; L
1067..106D    ; L
106E..1070    ; L
1075..1081    ; L
1083..1084    ; L
1087..108C    ; L
108E          ; L
108F          ; L
1090..1099    ; L
109A..109C    ; L
109E..109F    ; L
10A0..10C5    ; L
10C7          ; L
10CD          ; L
10D0..10FA    ; L
10FB          ; L
10FC          ; L
10FD..10FF    ; L
1100..1248    ; L
124A..124D    ; L
1250..1256    ; L
1258          ; L
125A..125D    ; L
1260..1288    ; L
128A..128D    ; L
1290..12B0    ; L
12B2..12B5    ; L
12B8..12BE    ; L
12C0          ; L
12C2..12C5    ; L
12C8..12D6    ; L
12D8..1310    ; L
1312..1315    ; L
1318..135A    ; L
1360..1368    ; L
1369..137C    ; L
1380..138F    ; L
13A0..13F5    ; L
13F8..13FD    ; L
1401..166C    ; L
166D          ; L
166E          ; L
166F..167F    ; L
1681..169A    ; L
16A0..16EA    ; L
16EB..16ED    ; L
16EE..16F0    ; L
16F1..16F8    ; L
1700..1711    ; L
1715          ; L
171F..1731    ; L
1734          ; L
1735..1736    ; L
1740..1751    ; L
1760..176C    ; L
176E..1770    ; L
1780..17B3    ; L
17B6          ; L
17BE..17C5    ; L
17C7..17C8    ; L
17D4..17D6    ; L
17D7          ; L
17D8..17DA    ; L
17DC          ; L
17E0..17E9    ; L
1810..1819    ; L
1820..1842    ; L
1843          ; L
1844..1878    ; L
1880..1884    ; L
1887..18A8    ; L
18AA          ; L
18B0..18F5    ; L
1900..191E    ; L
1923..1926    ; L
1929..192B    ; L
1930..1931    ; L
1933..1938    ; L
1946..194F    ; L
1950..196D    ; L
1970..1974    ; L
1980..19AB    ; L
19B0..19C9    ; L
19D0..19D9    ; L
19DA          ; L
1A00..1A16    ; L
1A19..1A1A    ; L
1A1E..1A1F    ; L
1A20..1A54    ; L
1A55          ; L
1A57          ; L
1A61          ; L
1A63..1A64    ; L
1A6D..1A72    ; L
1A80..1A89    ; L
1A90..1A99    ; L
1AA0..1AA6    ; L
1AA7          ; L
1AA8..1AAD    ; L
1B04          ; L
1B05..1B33    ; L
1B35          ; L
1B3B          ; L
1B3D..1B41    ; L
1B43..1B44    ; L
1B45..1B4C    ; L
1B4E..1B4F    ; L
1B50..1B59    ; L
1B5A..1B60    ; L
1B61..1B6A    ; L
1B74..1B7C    ; L
1B7D..1B7F    ; L
1B82          ; L
1B83..1BA0    ; L
1BA1          ; L
1BA6..1BA7    ; L
1BAA          ; L
1BAE..1BAF    ; L
1BB0..1BB9    ; L
1BBA..1BE5    ; L
1BE7          ; L
1BEA..1BEC    ; L
1BEE          ; L
1BF2..1BF3    ; L
1BFC..1BFF    ; L
1C00..1C23    ; L
1C24..1C2B    ; L
1C34..1C35    ; L
1C3B..1C3F    ; L
1C40..1C49    ; L
1C4D..1C4F    ; L
1C50..1C59    ; L
1C5A..1C77    ; L
1C78..1C7D    ; L
1C7E..1C7F    ; L
1C80..1C8A    ; L
1C90..1CBA    ; L
1CBD..1CBF    ; L
1CC0..1CC7    ; L
1CD3          ; L
1CE1          ; L
1CE9..1CEC    ; L
1CEE..1CF3    ; L
1CF5..1CF6    ; L
1CF7          ; L
1CFA          ; L
1D00..1D2B    ; L
1D2C..1D6A    ; L
1D6B..1D77    ; L
1D78          ; L
1D79..1D9A    ; L
1D9B..1DBF    ; L
1E00..1F15    ; L
1F18..1F1D    ; L
1F20..1F45    ; L
1F48..1F4D    ; L
1F50..1F57    ; L
1F59          ; L
1F5B          ; L
1F5D          ; L
1F5F..1F7D    ; L
1F80..1FB4    ; L
1FB6..1FBC    ; L
1FBE          ; L
1FC2..1FC4    ; L
1FC6..1FCC    ; L
1FD0..1FD3    ; L
1FD6..1FDB    ; L
1FE0..1FEC    ; L
1FF2..1FF4    ; L
1FF6..1FFC    ; L
200E          ; L
2071          ; L
207F          ; L
2090..209C    ; L
2102          ; L
2107          ; L
210A..2113    ; L
2115          ; L
2119..211D    ; L
2124          ; L
2126          ; L
2128          ; L
212A..212D    ; L
212F..2134    ; L
2135..2138    ; L
2139          ; L
213C..213F    ; L
2145..2149    ; L
214E          ; L
214F          ; L
2160..2182    ; L
2183..2184    ; L
2185..2188    ; L
2336..237A    ; L
2395          ; L
249C..24E9    ; L
26AC          ; L
2800..28FF    ; L
2C00..2C7B    ; L
2C7C..2C7D    ; L
2C7E..2CE4    ; L
2CEB..2CEE    ; L
2CF2..2CF3    ; L
2D00..2D25    ; L
2D27          ; L
2D2D          ; L
2D30..2D67    ; L
2D6F          ; L
2D70          ; L
2D80..2D96    ; L
2DA0..2DA6    ; L
2DA8..2DAE    ; L
2DB0..2DB6    ; L
2DB8..2DBE    ; L
2DC0..2DC6    ; L
2DC8..2DCE    ; L
2DD0..2DD6    ; L
2DD8..2DDE    ; L
3005          ; L
3006          ; L
3007          ; L
3021..3029    ; L
302E..302F    ; L
3031..3035    ; L
3038..303A    ; L
303B          ; L
303C          ; L
3041..3096    ; L
309D..309E    ; L
309F          ; L
30A1..30FA    ; L
30FC..30FE    ; L
30FF          ; L
3105..312F    ; L
3131..318E    ; L
3190..3191    ; L
3192..3195    ; L
3196..319F    ; L
31A0..31BF    ; L
31F0..31FF    ; L
3200..321C    ; L
3220..3229    ; L
322A..3247    ; L
3248..324F    ; L
3260..327B    ; L
327F          ; L
3280..3289    ; L
328A..32B0    ; L
32C0..32CB    ; L
32D0..3376    ; L
337B..33DD    ; L
33E0..33FE    ; L
3400..4DBF    ; L
4E00..A014    ; L
A015          ; L
A016..A48C    ; L
A4D0..A4F7    ; L
A4F8..A4FD    ; L
A4FE..A4FF    ; L
A500..A60B    ; L
A60C          ; L
A610..A61F    ; L
A620..A629    ; L
A62A..A62B    ; L
A640..A66D    ; L
A66E          ; L
A680..A69B    ; L
A69C..A69D    ; L
A6A0..A6E5    ; L
A6E6..A6EF    ; L
A6F2..A6F7    ; L
A722..A76F    ; L
A770          ; L
A771..A787    ; L
A789..A78A    ; L
A78B..A78E    ; L
A78F          ; L
A790..A7DC    ; L
A7F1..A7F4    ; L
A7F5..A7F6    ; L
A7F7          ; L
A7F8..A7F9    ; L
A7FA          ; L
A7FB..A801    ; L
A803..A805    ; L
A807..A80A    ; L
A80C..A822    ; L
A823..A824    ; L
A827          ; L
A830..A835    ; L
A836..A837    ; L
A840..A873    ; L
A880..A881    ; L
A882..A8B3    ; L
A8B4..A8C3    ; L
A8CE..A8CF    ; L
A8D0..A8D9    ; L
A8F2..A8F7    ; L
A8F8..A8FA    ; L
A8FB          ; L
A8FC          ; L
A8FD..A8FE    ; L
A900..A909    ; L
A90A..A925    ; L
A92E..A92F    ; L
A930..A946    ; L
A952..A953    ; L
A95F          ; L
A960..A97C    ; L
A983          ; L
A984..A9B2    ; L
A9B4..A9B5    ; L
A9BA..A9BB    ; L
A9BE..A9C0    ; L
A9C1..A9CD    ; L
A9CF          ; L
A9D0..A9D9    ; L
A9DE..A9DF    ; L
A9E0..A9E4    ; L
A9E6          ; L
A9E7..A9EF    ; L
A9F0..A9F9    ; L
A9FA..A9FE    ; L
AA00..AA28    ; L
AA2F..AA30    ; L
AA33..AA34    ; L
AA40..AA42    ; L
AA44..AA4B    ; L
AA4D          ; L
AA50..AA59    ; L
AA5C..AA5F    ; L
AA60..AA6F    ; L
AA70          ; L
AA71..AA76    ; L
AA77..AA79    ; L
AA7A          ; L
AA7B          ; L
AA7D          ; L
AA7E..AAAF    ; L
AAB1          ; L
AAB5..AAB6    ; L
AAB9..AABD    ; L
AAC0          ; L
AAC2          ; L
AADB..AADC    ; L
AADD          ; L
AADE..AADF    ; L
AAE0..AAEA    ; L
AAEB          ; L
AAEE..AAEF    ; L
AAF0..AAF1    ; L
AAF2          ; L
AAF3..AAF4    ; L
AAF5          ; L
AB01..AB06    ; L
AB09..AB0E    ; L
AB11..AB16    ; L
AB20..AB26    ; L
AB28..AB2E    ; L
AB30..AB5A    ; L
AB5B          ; L
AB5C..AB5F    ; L
AB60..AB68    ; L
AB69          ; L
AB70..ABBF    ; L
ABC0..ABE2    ; L
ABE3..ABE4    ; L
ABE6..ABE7    ; L
ABE9..ABEA    ; L
ABEB          ; L
ABEC          ; L
ABF0..ABF9    ; L
AC00..D7A3    ; L
D7B0..D7C6    ; L
D7CB..D7FB    ; L
E000..F8FF    ; L
F900..FA6D    ; L
FA70..FAD9    ; L
FB00..FB06    ; L
FB13..FB17    ; L
FF21..FF3A    ; L
FF41..FF5A    ; L
FF66..FF6F    ; L
FF70          ; L
FF71..FF9D    ; L
FF9E..FF9F    ; L
FFA0..FFBE    ; L
FFC2..FFC7    ; L
FFCA..FFCF    ; L
FFD2..FFD7    ; L
FFDA..FFDC    ; L
10000..1000B  ; L
1000D..10026  ; L
10028..1003A  ; L
1003C..1003D  ; L
1003F..1004D  ; L
10050..1005D  ; L
10080..100FA  ; L
10100         ; L
10102         ; L
10107..10133  ; L
10137..1013F  ; L
1018D..1018E  ; L
101D0..101FC  ; L
10280..1029C  ; L
102A0..102D0  ; L
10300..1031F  ; L
10320..10323  ; L
1032D..10340  ; L
10341         ; L
10342..10349  ; L
1034A         ; L
10350..10375  ; L
10380..1039D  ; L
1039F         ; L
103A0..103C3  ; L
103C8..103CF  ; L
103D0         ; L
103D1..103D5  ; L
10400..1044F  ; L
10450..1049D  ; L
104A0..104A9  ; L
104B0..104D3  ; L
104D8..104FB  ; L
10500..10527  ; L
10530..10563  ; L
1056F         ; L
10570..1057A  ; L
1057C..1058A  ; L
1058C..10592  ; L
10594..10595  ; L
10597..105A1  ; L
105A3..105B1  ; L
105B3..105B9  ; L
105BB..105BC  ; L
105C0..105F3  ; L
10600..10736  ; L
10740..10755  ; L
10760..10767  ; L
10780..10785  ; L
10787..107B0  ; L
107B2..107BA  ; L
11000         ; L
11002         ; L
11003..11037  ; L
11047..1104D  ; L
11066..1106F  ; L
11071..11072  ; L
11075         ; L
11082         ; L
11083..110AF  ; L
110B0..110B2  ; L
110B7..110B8  ; L
110BB..110BC  ; L
110BD         ; L
110BE..110C1  ; L
110CD         ; L
110D0..110E8  ; L
110F0..110F9  ; L
11103..11126  ; L
1112C         ; L
11136..1113F  ; L
11140..11143  ; L
11144         ; L
11145..11146  ; L
11147         ; L
11150..11172  ; L
11174..11175  ; L
11176         ; L
11182         ; L
11183..111B2  ; L
111B3..111B5  ; L
111BF..111C0  ; L
111C1..111C4  ; L
111C5..111C8  ; L
111CD         ; L
111CE         ; L
111D0..111D9  ; L
111DA         ; L
111DB         ; L
111DC         ; L
111DD..111DF  ; L
111E1..111F4  ; L
11200..11211  ; L
11213..1122B  ; L
1122C..1122E  ; L
11232..11233  ; L
11235         ; L
11238..1123D  ; L
1123F..11240  ; L
11280..11286  ; L
11288         ; L
1128A..1128D  ; L
1128F..1129D  ; L
1129F..112A8  ; L
112A9         ; L
112B0..112DE  ; L
112E0..112E2  ; L
112F0..112F9  ; L
11302..11303  ; L
11305..1130C  ; L
1130F..11310  ; L
11313..11328  ; L
1132A..11330  ; L
11332..11333  ; L
11335..11339  ; L
1133D         ; L
1133E..1133F  ; L
11341..11344  ; L
11347..11348  ; L
1134B..1134D  ; L
11350         ; L
11357         ; L
1135D..11361  ; L
11362..11363  ; L
11380..11389  ; L
1138B         ; L
1138E         ; L
11390..113B5  ; L
113B7         ; L
113B8..113BA  ; L
113C2         ; L
113C5         ; L
113C7..113CA  ; L
113CC..113CD  ; L
113CF         ; L
113D1         ; L
113D3         ; L
113D4..113D5  ; L
113D7..113D8  ; L
11400..11434  ; L
11435..11437  ; L
11440..11441  ; L
11445         ; L
11447..1144A  ; L
1144B..1144F  ; L
11450..11459  ; L
1145A..1145B  ; L
1145D         ; L
1145F..11461  ; L
11480..114AF  ; L
114B0..114B2  ; L
114B9         ; L
114BB..114BE  ; L
114C1         ; L
114C4..114C5  ; L
114C6         ; L
114C7         ; L
114D0..114D9  ; L
11580..115AE  ; L
115AF..115B1  ; L
115B8..115BB  ; L
115BE         ; L
115C1..115D7  ; L
115D8..115DB  ; L
11600..1162F  ; L
11630..11632  ; L
1163B..1163C  ; L
1163E         ; L
11641..11643  ; L
11644         ; L
11650..11659  ; L
11680..116AA  ; L
116AC         ; L
116AE..116AF  ; L
116B6         ; L
116B8         ; L
116B9         ; L
116C0..116C9  ; L
116D0..116E3  ; L
11700..1171A  ; L
1171E         ; L
11720..11721  ; L
11726         ; L
11730..11739  ; L
1173A..1173B  ; L
1173C..1173E  ; L
1173F         ; L
11740..11746  ; L
11800..1182B  ; L
1182C..1182E  ; L
11838         ; L
1183B         ; L
118A0..118DF  ; L
118E0..118E9  ; L
118EA..118F2  ; L
118FF..11906  ; L
11909         ; L
1190C..11913  ; L
11915..11916  ; L
11918..1192F  ; L
11930..11935  ; L
11937..11938  ; L
1193D         ; L
1193F         ; L
11940         ; L
11941         ; L
11942         ; L
11944..11946  ; L
11950..11959  ; L
119A0..119A7  ; L
119AA..119D0  ; L
119D1..119D3  ; L
119DC..119DF  ; L
119E1         ; L
119E2         ; L
119E3         ; L
119E4         ; L
11A00         ; L
11A07..11A08  ; L
11A0B..11A32  ; L
11A39         ; L
11A3A         ; L
11A3F..11A46  ; L
11A50         ; L
11A57..11A58  ; L
11A5C..11A89  ; L
11A97         ; L
11A9A..11A9C  ; L
11A9D         ; L
11A9E..11AA2  ; L
11AB0..11AF8  ; L
11B00..11B09  ; L
11B61         ; L
11B65         ; L
11B67         ; L
11BC0..11BE0  ; L
11BE1         ; L
11BF0..11BF9  ; L
11C00..11C08  ; L
11C0A..11C2E  ; L
11C2F         ; L
11C3E         ; L
11C3F         ; L
11C40         ; L
11C41..11C45  ; L
11C50..11C59  ; L
11C5A..11C6C  ; L
11C70..11C71  ; L
11C72..11C8F  ; L
11CA9         ; L
11CB1         ; L
11CB4         ; L
11D00..11D06  ; L
11D08..11D09  ; L
11D0B..11D30  ; L
11D46         ; L
11D50..11D59  ; L
11D60..11D65  ; L
11D67..11D68  ; L
11D6A..11D89  ; L
11D8A..11D8E  ; L
11D93..11D94  ; L
11D96         ; L
11D98         ; L
11DA0..11DA9  ; L
11DB0..11DD8  ; L
11DD9         ; L
11DDA..11DDB  ; L
11DE0..11DE9  ; L
11EE0..11EF2  ; L
11EF5..11EF6  ; L
11EF7..11EF8  ; L
11F02         ; L
11F03         ; L
11F04..11F10  ; L
11F12..11F33  ; L
11F34..11F35  ; L
11F3E..11F3F  ; L
11F41         ; L
11F43..11F4F  ; L
11F50..11F59  ; L
11FB0         ; L
11FC0..11FD4  ; L
11FFF         ; L
12000..12399  ; L
12400..1246E  ; L
12470..12474  ; L
12480..12543  ; L
12F90..12FF0  ; L
12FF1..12FF2  ; L
13000..1342F  ; L
13430..1343F  ; L
13441..13446  ; L
13460..143FA  ; L
14400..14646  ; L
16100..1611D  ; L
1612A..1612C  ; L
16130..16139  ; L
16800..16A38  ; L
16A40..16A5E  ; L
16A60..16A69  ; L
16A6E..16A6F  ; L
16A70..16ABE  ; L
16AC0..16AC9  ; L
16AD0..16AED  ; L
16AF5         ; L
16B00..16B2F  ; L
16B37..16B3B  ; L
16B3C..16B3F  ; L
16B40..16B43  ; L
16B44         ; L
16B45         ; L
16B50..16B59  ; L
16B5B..16B61  ; L
16B63..16B77  ; L
16B7D..16B8F  ; L
16D40..16D42  ; L
16D43..16D6A  ; L
16D6B..16D6C  ; L
16D6D..16D6F  ; L
16D70..16D79  ; L
16E40..16E7F  ; L
16E80..16E96  ; L
16E97..16E9A  ; L
16EA0..16EB8  ; L
16EBB..16ED3  ; L
16F00..16F4A  ; L
16F50         ; L
16F51..16F87  ; L
16F93..16F9F  ; L
16FE0..16FE1  ; L
16FE3         ; L
16FF0..16FF1  ; L
16FF2..16FF3  ; L
16FF4..16FF6  ; L
17000..18CD5  ; L
18CFF..18D1E  ; L
18D80..18DF2  ; L
1AFF0..1AFF3  ; L
1AFF5..1AFFB  ; L
1AFFD..1AFFE  ; L
1B000..1B122  ; L
1B132         ; L
1B150..1B152  ; L
1B155         ; L
1B164..1B167  ; L
1B170..1B2FB  ; L
1BC00..1BC6A  ; L
1BC70..1BC7C  ; L
1BC80..1BC88  ; L
1BC90..1BC99  ; L
1BC9C         ; L
1BC9F         ; L
1CCD6..1CCEF  ; L
1CF50..1CFC3  ; L
1D000..1D0F5  ; L
1D100..1D126  ; L
1D129..1D164  ; L
1D165..1D166  ; L
1D16A..1D16C  ; L
1D16D..1D172  ; L
1D183..1D184  ; L
1D18C..1D1A9  ; L
1D1AE..1D1E8  ; L
1D2C0..1D2D3  ; L
1D2E0..1D2F3  ; L
1D360..1D378  ; L
1D400..1D454  ; L
1D456..1D49C  ; L
1D49E..1D49F  ; L
1D4A2         ; L
1D4A5..1D4A6  ; L
1D4A9..1D4AC  ; L
1D4AE..1D4B9  ; L
1D4BB         ; L
1D4BD..1D4C3  ; L
1D4C5..1D505  ; L
1D507..1D50A  ; L
1D50D..1D514  ; L
1D516..1D51C  ; L
1D51E..1D539  ; L
1D53B..1D53E  ; L
1D540..1D544  ; L
1D546         ; L
1D54A..1D550  ; L
1D552..1D6A5  ; L
1D6A8..1D6C0  ; L
1D6C2..1D6DA  ; L
1D6DC..1D6FA  ; L
1D6FC..1D714  ; L
1D716..1D734  ; L
1D736..1D74E  ; L
1D750..1D76E  ; L
1D770..1D788  ; L
1D78A..1D7A8  ; L
1D7AA..1D7C2  ; L
1D7C4..1D7CB  ; L
1D800..1D9FF  ; L
1DA37..1DA3A  ; L
1DA6D..1DA74  ; L
1DA76..1DA83  ; L
1DA85..1DA86  ; L
1DA87..1DA8B  ; L
1DF00..1DF09  ; L
1DF0A         ; L
1DF0B..1DF1E  ; L
1DF25..1DF2A  ; L
1E030..1E06D  ; L
1E100..1E12C  ; L
1E137..1E13D  ; L
1E140..1E149  ; L
1E14E         ; L
1E14F         ; L
1E290..1E2AD  ; L
1E2C0..1E2EB  ; L
1E2F0..1E2F9  ; L
1E4D0..1E4EA  ; L
1E4EB         ; L
1E4F0..1E4F9  ; L
1E5D0..1E5ED  ; L
1E5F0         ; L
1E5F1..1E5FA  ; L
1E5FF         ; L
1E6C0..1E6DE  ; L
1E6E0..1E6E2  ; L
1E6E4..1E6E5  ; L
1E6E7..1E6ED  ; L
1E6F0..1E6F4  ; L
1E6FE         ; L
1E6FF         ; L
1E7E0..1E7E6  ; L
1E7E8..1E7EB  ; L
1E7ED..1E7EE  ; L
1E7F0..1E7FE  ; L
1F110..1F12E  ; L
1F130..1F169  ; L
1F170..1F1AC  ; L
1F1E6..1F202  ; L
1F210..1F23B  ; L
1F240..1F248  ; L
1F250..1F251  ; L
20000..2A6DF  ; L
2A700..2B81D  ; L
2B820..2CEAD  ; L
2CEB0..2EBE0  ; L
2EBF0..2EE5D  ; L
2F800..2FA1D  ; L
30000..3134A  ; L
31350..33479  ; L
F0000..FFFFD  ; L
100000..10FFFD; L
05BE          ; R
05C0          ; R
05C3          ; R
05C6          ; R
05D0..05EA    ; R
05EF..05F2    ; R
05F3..05F4    ; R
07C0..07C9    ; R
07CA..07EA    ; R
07F4..07F5    ; R
07FA          ; R
07FE..07FF    ; R
0800..0815    ; R
081A          ; R
0824          ; R
0828          ; R
0830..083E    ; R
0840..0858    ; R
085E          ; R
200F          ; R
FB1D          ; R
FB1F..FB28    ; R
FB2A..FB36    ; R
FB38..FB3C    ; R
FB3E          ; R
FB40..FB41    ; R
FB43..FB44    ; R
FB46..FB4F    ; R
10800..10805  ; R
10808         ; R
1080A..10835  ; R
10837..10838  ; R
1083C         ; R
1083F..10855  ; R
10857         ; R
10858..1085F  ; R
10860..10876  ; R
10877..10878  ; R
10879..1087F  ; R
10880..1089E  ; R
108A7..108AF  ; R
108E0..108F2  ; R
108F4..108F5  ; R
108FB..108FF  ; R
10900..10915  ; R
10916..1091B  ; R
10920..10939  ; R
1093F         ; R
10940..10959  ; R
10980..109B7  ; R
109BC..109BD  ; R
109BE..109BF  ; R
109C0..109CF  ; R
109D2..109FF  ; R
10A00         ; R
10A10..10A13  ; R
10A15..10A17  ; R
10A19..10A35  ; R
10A40..10A48  ; R
10A50..10A58  ; R
10A60..10A7C  ; R
10A7D..10A7E  ; R
10A7F         ; R
10A80..10A9C  ; R
10A9D..10A9F  ; R
10AC0..10AC7  ; R
10AC8         ; R
10AC9..10AE4  ; R
10AEB..10AEF  ; R
10AF0..10AF6  ; R
10B00..10B35  ; R
10B40..10B55  ; R
10B58..10B5F  ; R
10B60..10B72  ; R
10B78..10B7F  ; R
10B80..10B91  ; R
10B99..10B9C  ; R
10BA9..10BAF  ; R
10C00..10C48  ; R
10C80..10CB2  ; R
10CC0..10CF2  ; R
10CFA..10CFF  ; R
10D4A..10D4D  ; R
10D4E         ; R
10D4F         ; R
10D50..10D65  ; R
10D6F         ; R
10D70..10D85  ; R
10D8E..10D8F  ; R
10E80..10EA9  ; R
10EAD         ; R
10EB0..10EB1  ; R
10F00..10F1C  ; R
10F1D..10F26  ; R
10F27         ; R
10F70..10F81  ; R
10F86..10F89  ; R
10FB0..10FC4  ; R
10FC5..10FCB  ; R
10FE0..10FF6  ; R
1E800..1E8C4  ; R
1E8C7..1E8CF  ; R
1E900..1E943  ; R
1E94B         ; R
1E950..1E959  ; R
1E95E..1E95F  ; R
0030..0039    ; EN
00B2..00B3    ; EN
00B9          ; EN
06F0..06F9    ; EN
2070          ; EN
2074..2079    ; EN
2080..2089    ; EN
2488..249B    ; EN
FF10..FF19    ; EN
102E1..102FB  ; EN
1CCF0..1CCF9  ; EN
1D7CE..1D7FF  ; EN
1F100..1F10A  ; EN
1FBF0..1FBF9  ; EN
002B          ; ES
002D          ; ES
207A..207B    ; ES
208A..208B    ; ES
2212          ; ES
FB29          ; ES
FE62          ; ES
FE63          ; ES
FF0B          ; ES
FF0D          ; ES
0023          ; ET
0024          ; ET
0025          ; ET
00A2..00A5    ; ET
00B0          ; ET
00B1          ; ET
058F          ; ET
0609..060A    ; ET
066A          ; ET
09F2..09F3    ; ET
09FB          ; ET
0AF1          ; ET
0BF9          ; ET
0E3F          ; ET
17DB          ; ET
2030..2034    ; ET
20A0..20C1    ; ET
212E          ; ET
2213          ; ET
A838          ; ET
A839          ; ET
FE5F          ; ET
FE69          ; ET
FE6A          ; ET
FF03          ; ET
FF04          ; ET
FF05          ; ET
FFE0..FFE1    ; ET
FFE5..FFE6    ; ET
11FDD..11FE0  ; ET
1E2FF         ; ET
0600..0605    ; AN
0660..0669    ; AN
066B..066C    ; AN
06DD          ; AN
0890..0891    ; AN
08E2          ; AN
10D30..10D39  ; AN
10D40..10D49  ; AN
10E60..10E7E  ; AN
002C          ; CS
002E..002F    ; CS
003A          ; CS
00A0          ; CS
060C          ; CS
202F          ; CS
2044          ; CS
FE50          ; CS
FE52          ; CS
FE55          ; CS
FF0C          ; CS
FF0E..FF0F    ; CS
FF1A          ; CS
000A          ; B
000D          ; B
001C..001E    ; B
0085          ; B
2029          ; B
0009          ; S
000B          ; S
001F          ; S
000C          ; WS
0020          ; WS
1680          ; WS
2000..200A    ; WS
2028          ; WS
205F          ; WS
3000          ; WS
0021..0022    ; ON
0026..0027    ; ON
0028          ; ON
0029          ; ON
002A          ; ON
003B          ; ON
003C..003E    ; ON
003F..0040    ; ON
005B          ; ON
005C          ; ON
005D          ; ON
005E          ; ON
005F          ; ON
0060          ; ON
007B          ; ON
007C          ; ON
007D          ; ON
007E          ; ON
00A1          ; ON
00A6          ; ON
00A7          ; ON
00A8          ; ON
00A9          ; ON
00AB          ; ON
00AC          ; ON
00AE          ; ON
00AF          ; ON
00B4          ; ON
00B6..00B7    ; ON
00B8          ; ON
00BB          ; ON
00BC..00BE    ; ON
00BF          ; ON
00D7          ; ON
00F7          ; ON
02B9..02BA    ; ON
02C2..02C5    ; ON
02C6..02CF    ; ON
02D2..02DF    ; ON
02E5..02EB    ; ON
02EC          ; ON
02ED          ; ON
02EF..02FF    ; ON
0374          ; ON
0375          ; ON
037E          ; ON
0384..0385    ; ON
0387          ; ON
03F6          ; ON
058A          ; ON
058D..058E    ; ON
0606..0607    ; ON
060E..060F    ; ON
06DE          ; ON
06E9          ; ON
07F6          ; ON
07F7..07F9    ; ON
0BF3..0BF8    ; ON
0BFA          ; ON
0C78..0C7E    ; ON
0F3A          ; ON
0F3B          ; ON
0F3C          ; ON
0F3D          ; ON
1390..1399    ; ON
1400          ; ON
169B          ; ON
169C          ; ON
17F0..17F9    ; ON
1800..1805    ; ON
1806          ; ON
1807..180A    ; ON
1940          ; ON
1944..1945    ; ON
19DE..19FF    ; ON
1FBD          ; ON
1FBF..1FC1    ; ON
1FCD..1FCF    ; ON
1FDD..1FDF    ; ON
1FED..1FEF    ; ON
1FFD..1FFE    ; ON
2010..2015    ; ON
2016..2017    ; ON
2018          ; ON
2019          ; ON
201A          ; ON
201B..201C    ; ON
201D          ; ON
201E          ; ON
201F          ; ON
2020..2027    ; ON
2035..2038    ; ON
2039          ; ON
203A          ; ON
203B..203E    ; ON
203F..2040    ; ON
2041..2043    ; ON
2045          ; ON
2046          ; ON
2047..2051    ; ON
2052          ; ON
2053          ; ON
2054          ; ON
2055..205E    ; ON
207C          ; ON
207D          ; ON
207E          ; ON
208C          ; ON
208D          ; ON
208E          ; ON
2100..2101    ; ON
2103..2106    ; ON
2108..2109    ; ON
2114          ; ON
2116..2117    ; ON
2118          ; ON
211E..2123    ; ON
2125          ; ON
2127          ; ON
2129          ; ON
213A..213B    ; ON
2140..2144    ; ON
214A          ; ON
214B          ; ON
214C..214D    ; ON
2150..215F    ; ON
2189          ; ON
218A..218B    ; ON
2190..2194    ; ON
2195..2199    ; ON
219A..219B    ; ON
219C..219F    ; ON
21A0          ; ON
21A1..21A2    ; ON
21A3          ; ON
21A4..21A5    ; ON
21A6          ; ON
21A7..21AD    ; ON
21AE          ; ON
21AF..21CD    ; ON
21CE..21CF    ; ON
21D0..21D1    ; ON
21D2          ; ON
21D3          ; ON
21D4          ; ON
21D5..21F3    ; ON
21F4..2211    ; ON
2214..22FF    ; ON
2300..2307    ; ON
2308          ; ON
2309          ; ON
230A          ; ON
230B          ; ON
230C..231F    ; ON
2320..2321    ; ON
2322..2328    ; ON
2329          ; ON
232A          ; ON
232B..2335    ; ON
237B          ; ON
237C          ; ON
237D..2394    ; ON
2396..239A    ; ON
239B..23B3    ; ON
23B4..23DB    ; ON
23DC..23E1    ; ON
23E2..2429    ; ON
2440..244A    ; ON
2460..2487    ; ON
24EA..24FF    ; ON
2500..25B6    ; ON
25B7          ; ON
25B8..25C0    ; ON
25C1          ; ON
25C2..25F7    ; ON
25F8..25FF    ; ON
2600..266E    ; ON
266F          ; ON
2670..26AB    ; ON
26AD..2767    ; ON
2768          ; ON
2769          ; ON
276A          ; ON
276B          ; ON
276C          ; ON
276D          ; ON
276E          ; ON
276F          ; ON
2770          ; ON
2771          ; ON
2772          ; ON
2773          ; ON
2774          ; ON
2775          ; ON
2776..2793    ; ON
2794..27BF    ; ON
27C0..27C4    ; ON
27C5          ; ON
27C6          ; ON
27C7..27E5    ; ON
27E6          ; ON
27E7          ; ON
27E8          ; ON
27E9          ; ON
27EA          ; ON
27EB          ; ON
27EC          ; ON
27ED          ; ON
27EE          ; ON
27EF          ; ON
27F0..27FF    ; ON
2900..2982    ; ON
2983          ; ON
2984          ; ON
2985          ; ON
2986          ; ON
2987          ; ON
2988          ; ON
2989          ; ON
298A          ; ON
298B          ; ON
298C          ; ON
298D          ; ON
298E          ; ON
298F          ; ON
2990          ; ON
2991          ; ON
2992          ; ON
2993          ; ON
2994          ; ON
2995          ; ON
2996          ; ON
2997          ; ON
2998          ; ON
2999..29D7    ; ON
29D8          ; ON
29D9          ; ON
29DA          ; ON
29DB          ; ON
29DC..29FB    ; ON
29FC          ; ON
29FD          ; ON
29FE..2AFF    ; ON
2B00..2B2F    ; ON
2B30..2B44    ; ON
2B45..2B46    ; ON
2B47..2B4C    ; ON
2B4D..2B73    ; ON
2B76..2BFF    ; ON
2CE5..2CEA    ; ON
2CF9..2CFC    ; ON
2CFD          ; ON
2CFE..2CFF    ; ON
2E00..2E01    ; ON
2E02          ; ON
2E03          ; ON
2E04          ; ON
2E05          ; ON
2E06..2E08    ; ON
2E09          ; ON
2E0A          ; ON
2E0B          ; ON
2E0C          ; ON
2E0D          ; ON
2E0E..2E16    ; ON
2E17          ; ON
2E18..2E19    ; ON
2E1A          ; ON
2E1B          ; ON
2E1C          ; ON
2E1D          ; ON
2E1E..2E1F    ; ON
2E20          ; ON
2E21          ; ON
2E22          ; ON
2E23          ; ON
2E24          ; ON
2E25          ; ON
2E26          ; ON
2E27          ; ON
2E28          ; ON
2E29          ; ON
2E2A..2E2E    ; ON
2E2F          ; ON
2E30..2E39    ; ON
2E3A..2E3B    ; ON
2E3C..2E3F    ; ON
2E40          ; ON
2E41          ; ON
2E42          ; ON
2E43..2E4F    ; ON
2E50..2E51    ; ON
2E52..2E54    ; ON
2E55          ; ON
2E56          ; ON
2E57          ; ON
2E58          ; ON
2E59          ; ON
2E5A          ; ON
2E5B          ; ON
2E5C          ; ON
2E5D          ; ON
2E80..2E99    ; ON
2E9B..2EF3    ; ON
2F00..2FD5    ; ON
2FF0..2FFF    ; ON
3001..3003    ; ON
3004          ; ON
3008          ; ON
3009          ; ON
300A          ; ON
300B          ; ON
300C          ; ON
300D          ; ON
300E          ; ON
300F          ; ON
3010          ; ON
3011          ; ON
3012..3013    ; ON
3014          ; ON
3015          ; ON
3016          ; ON
3017          ; ON
3018          ; ON
3019          ; ON
301A          ; ON
301B          ; ON
301C          ; ON
301D          ; ON
301E..301F    ; ON
3020          ; ON
3030          ; ON
3036..3037    ; ON
303D          ; ON
303E..303F    ; ON
309B..309C    ; ON
30A0          ; ON
30FB          ; ON
31C0..31E5    ; ON
31EF          ; ON
321D..321E    ; ON
3250          ; ON
3251..325F    ; ON
327C..327E    ; ON
32B1..32BF    ; ON
32CC..32CF    ; ON
3377..337A    ; ON
33DE..33DF    ; ON
33FF          ; ON
4DC0..4DFF    ; ON
A490..A4C6    ; ON
A60D..A60F    ; ON
A673          ; ON
A67E          ; ON
A67F          ; ON
A700..A716    ; ON
A717..A71F    ; ON
A720..A721    ; ON
A788          ; ON
A828..A82B    ; ON
A874..A877    ; ON
AB6A..AB6B    ; ON
FBC3..FBD2    ; ON
FD3E          ; ON
FD3F          ; ON
FD40..FD4F    ; ON
FD90..FD91    ; ON
FDC8..FDCF    ; ON
FDFD..FDFF    ; ON
FE10..FE16    ; ON
FE17          ; ON
FE18          ; ON
FE19          ; ON
FE30          ; ON
FE31..FE32    ; ON
FE33..FE34    ; ON
FE35          ; ON
FE36          ; ON
FE37          ; ON
FE38          ; ON
FE39          ; ON
FE3A          ; ON
FE3B          ; ON
FE3C          ; ON
FE3D          ; ON
FE3E          ; ON
FE3F          ; ON
FE40          ; ON
FE41          ; ON
FE42          ; ON
FE43          ; ON
FE44          ; ON
FE45..FE46    ; ON
FE47          ; ON
FE48          ; ON
FE49..FE4C    ; ON
FE4D..FE4F    ; ON
FE51          ; ON
FE54          ; ON
FE56..FE57    ; ON
FE58          ; ON
FE59          ; ON
FE5A          ; ON
FE5B          ; ON
FE5C          ; ON
FE5D          ; ON
FE5E          ; ON
FE60..FE61    ; ON
FE64..FE66    ; ON
FE68          ; ON
FE6B          ; ON
FF01..FF02    ; ON
FF06..FF07    ; ON
FF08          ; ON
FF09          ; ON
FF0A          ; ON
FF1B          ; ON
FF1C..FF1E    ; ON
FF1F..FF20    ; ON
FF3B          ; ON
FF3C          ; ON
FF3D          ; ON
FF3E          ; ON
FF3F          ; ON
FF40          ; ON
FF5B          ; ON
FF5C          ; ON
FF5D          ; ON
FF5E          ; ON
FF5F          ; ON
FF60          ; ON
FF61          ; ON
FF62          ; ON
FF63          ; ON
FF64..FF65    ; ON
FFE2          ; ON
FFE3          ; ON
FFE4          ; ON
FFE8          ; ON
FFE9..FFEC    ; ON
FFED..FFEE    ; ON
FFF9..FFFB    ; ON
FFFC..FFFD    ; ON
10101         ; ON
10140..10174  ; ON
10175..10178  ; ON
10179..10189  ; ON
1018A..1018B  ; ON
1018C         ; ON
10190..1019C  ; ON
101A0         ; ON
1091F         ; ON
10B39..10B3F  ; ON
10D6E         ; ON
10ED0         ; ON
10ED1..10ED8  ; ON
11052..11065  ; ON
11660..1166C  ; ON
11FD5..11FDC  ; ON
11FE1..11FF1  ; ON
16FE2         ; ON
1CC00..1CCD5  ; ON
1CCFA..1CCFC  ; ON
1CD00..1CEB3  ; ON
1CEBA..1CED0  ; ON
1CEE0..1CEEF  ; ON
1CEF0         ; ON
1D1E9..1D1EA  ; ON
1D200..1D241  ; ON
1D245         ; ON
1D300..1D356  ; ON
1D6C1         ; ON
1D6DB         ; ON
1D6FB         ; ON
1D715         ; ON
1D735         ; ON
1D74F         ; ON
1D76F         ; ON
1D789         ; ON
1D7A9         ; ON
1D7C3         ; ON
1EEF0..1EEF1  ; ON
1F000..1F02B  ; ON
1F030..1F093  ; ON
1F0A0..1F0AE  ; ON
1F0B1..1F0BF  ; ON
1F0C1..1F0CF  ; ON
1F0D1..1F0F5  ; ON
1F10B..1F10C  ; ON
1F10D..1F10F  ; ON
1F12F         ; ON
1F16A..1F16F  ; ON
1F1AD         ; ON
1F260..1F265  ; ON
1F300..1F3FA  ; ON
1F3FB..1F3FF  ; ON
1F400..1F6D8  ; ON
1F6DC..1F6EC  ; ON
1F6F0..1F6FC  ; ON
1F700..1F7D9  ; ON
1F7E0..1F7EB  ; ON
1F7F0         ; ON
1F800..1F80B  ; ON
1F810..1F847  ; ON
1F850..1F859  ; ON
1F860..1F887  ; ON
1F890..1F8AD  ; ON
1F8B0..1F8BB  ; ON
1F8C0..1F8C1  ; ON
1F8D0..1F8D8  ; ON
1F900..1FA57  ; ON
1FA60..1FA6D  ; ON
1FA70..1FA7C  ; ON
1FA80..1FA8A  ; ON
1FA8E..1FAC6  ; ON
1FAC8         ; ON
1FACD..1FADC  ; ON
1FADF..1FAEA  ; ON
1FAEF..1FAF8  ; ON
1FB00..1FB92  ; ON
1FB94..1FBEF  ; ON
1FBFA         ; ON
0000..0008    ; BN
000E..001B    ; BN
007F..0084    ; BN
0086..009F    ; BN
00AD          ; BN
180E          ; BN
200B..200D    ; BN
2060..2064    ; BN
2065          ; BN
206A..206F    ; BN
FDD0..FDEF    ; BN
FEFF          ; BN
FFF0..FFF8    ; BN
FFFE..FFFF    ; BN
1BCA0..1BCA3  ; BN
1D173..1D17A  ; BN
1FFFE..1FFFF  ; BN
2FFFE..2FFFF  ; BN
3FFFE..3FFFF  ; BN
4FFFE..4FFFF  ; BN
5FFFE..5FFFF  ; BN
6FFFE..6FFFF  ; BN
7FFFE..7FFFF  ; BN
8FFFE..8FFFF  ; BN
9FFFE..9FFFF  ; BN
AFFFE..AFFFF  ; BN
BFFFE..BFFFF  ; BN
CFFFE..CFFFF  ; BN
DFFFE..E0000  ; BN
E0001         ; BN
E0002..E001F  ; BN
E0020..E007F  ; BN
E0080..E00FF  ; BN
E01F0..E0FFF  ; BN
EFFFE..EFFFF  ; BN
FFFFE..FFFFF  ; BN
10FFFE..10FFFF; BN
0300..036F    ; NSM
0483..0487    ; NSM
0488..0489    ; NSM
0591..05BD    ; NSM
05BF          ; NSM
05C1..05C2    ; NSM
05C4..05C5    ; NSM
05C7          ; NSM
0610..061A    ; NSM
064B..065F    ; NSM
0670          ; NSM
06D6..06DC    ; NSM
06DF..06E4    ; NSM
06E7..06E8    ; NSM
06EA..06ED    ; NSM
0711          ; NSM
0730..074A    ; NSM
07A6..07B0    ; NSM
07EB..07F3    ; NSM
07FD          ; NSM
0816..0819    ; NSM
081B..0823    ; NSM
0825..0827    ; NSM
0829..082D    ; NSM
0859..085B    ; NSM
0897..089F    ; NSM
08CA..08E1    ; NSM
08E3..0902    ; NSM
093A          ; NSM
093C          ; NSM
0941..0948    ; NSM
094D          ; NSM
0951..0957    ; NSM
0962..0963    ; NSM
0981          ; NSM
09BC          ; NSM
09C1..09C4    ; NSM
09CD          ; NSM
09E2..09E3    ; NSM
09FE          ; NSM
0A01..0A02    ; NSM
0A3C          ; NSM
0A41..0A42    ; NSM
0A47..0A48    ; NSM
0A4B..0A4D    ; NSM
0A51          ; NSM
0A70..0A71    ; NSM
0A75          ; NSM
0A81..0A82    ; NSM
0ABC          ; NSM
0AC1..0AC5    ; NSM
0AC7..0AC8    ; NSM
0ACD          ; NSM
0AE2..0AE3    ; NSM
0AFA..0AFF    ; NSM
0B01          ; NSM
0B3C          ; NSM
0B3F          ; NSM
0B41..0B44    ; NSM
0B4D          ; NSM
0B55..0B56    ; NSM
0B62..0B63    ; NSM
0B82          ; NSM
0BC0          ; NSM
0BCD          ; NSM
0C00          ; NSM
0C04          ; NSM
0C3C          ; NSM
0C3E..0C40    ; NSM
0C46..0C48    ; NSM
0C4A..0C4D    ; NSM
0C55..0C56    ; NSM
0C62..0C63    ; NSM
0C81          ; NSM
0CBC          ; NSM
0CCC..0CCD    ; NSM
0CE2..0CE3    ; NSM
0D00..0D01    ; NSM
0D3B..0D3C    ; NSM
0D41..0D44    ; NSM
0D4D          ; NSM
0D62..0D63    ; NSM
0D81          ; NSM
0DCA          ; NSM
0DD2..0DD4    ; NSM
0DD6          ; NSM
0E31          ; NSM
0E34..0E3A    ; NSM
0E47..0E4E    ; NSM
0EB1          ; NSM
0EB4..0EBC    ; NSM
0EC8..0ECE    ; NSM
0F18..0F19    ; NSM
0F35          ; NSM
0F37          ; NSM
0F39          ; NSM
0F71..0F7E    ; NSM
0F80..0F84    ; NSM
0F86..0F87    ; NSM
0F8D..0F97    ; NSM
0F99..0FBC    ; NSM
0FC6          ; NSM
102D..1030    ; NSM
1032..1037    ; NSM
1039..103A    ; NSM
103D..103E    ; NSM
1058..1059    ; NSM
105E..1060    ; NSM
1071..1074    ; NSM
1082          ; NSM
1085..1086    ; NSM
108D          ; NSM
109D          ; NSM
135D..135F    ; NSM
1712..1714    ; NSM
1732..1733    ; NSM
1752..1753    ; NSM
1772..1773    ; NSM
17B4..17B5    ; NSM
17B7..17BD    ; NSM
17C6          ; NSM
17C9..17D3    ; NSM
17DD          ; NSM
180B..180D    ; NSM
180F          ; NSM
1885..1886    ; NSM
18A9          ; NSM
1920..1922    ; NSM
1927..1928    ; NSM
1932          ; NSM
1939..193B    ; NSM
1A17..1A18    ; NSM
1A1B          ; NSM
1A56          ; NSM
1A58..1A5E    ; NSM
1A60          ; NSM
1A62          ; NSM
1A65..1A6C    ; NSM
1A73..1A7C    ; NSM
1A7F          ; NSM
1AB0..1ABD    ; NSM
1ABE          ; NSM
1ABF..1ADD    ; NSM
1AE0..1AEB    ; NSM
1B00..1B03    ; NSM
1B34          ; NSM
1B36..1B3A    ; NSM
1B3C          ; NSM
1B42          ; NSM
1B6B..1B73    ; NSM
1B80..1B81    ; NSM
1BA2..1BA5    ; NSM
1BA8..1BA9    ; NSM
1BAB..1BAD    ; NSM
1BE6          ; NSM
1BE8..1BE9    ; NSM
1BED          ; NSM
1BEF..1BF1    ; NSM
1C2C..1C33    ; NSM
1C36..1C37    ; NSM
1CD0..1CD2    ; NSM
1CD4..1CE0    ; NSM
1CE2..1CE8    ; NSM
1CED          ; NSM
1CF4          ; NSM
1CF8..1CF9    ; NSM
1DC0..1DFF    ; NSM
20D0..20DC    ; NSM
20DD..20E0    ; NSM
20E1          ; NSM
20E2..20E4    ; NSM
20E5..20F0    ; NSM
2CEF..2CF1    ; NSM
2D7F          ; NSM
2DE0..2DFF    ; NSM
302A..302D    ; NSM
3099..309A    ; NSM
A66F          ; NSM
A670..A672    ; NSM
A674..A67D    ; NSM
A69E..A69F    ; NSM
A6F0..A6F1    ; NSM
A802          ; NSM
A806          ; NSM
A80B          ; NSM
A825..A826    ; NSM
A82C          ; NSM
A8C4..A8C5    ; NSM
A8E0..A8F1    ; NSM
A8FF          ; NSM
A926..A92D    ; NSM
A947..A951    ; NSM
A980..A982    ; NSM
A9B3          ; NSM
A9B6..A9B9    ; NSM
A9BC..A9BD    ; NSM
A9E5          ; NSM
AA29..AA2E    ; NSM
AA31..AA32    ; NSM
AA35..AA36    ; NSM
AA43          ; NSM
AA4C          ; NSM
AA7C          ; NSM
AAB0          ; NSM
AAB2..AAB4    ; NSM
AAB7..AAB8    ; NSM
AABE..AABF    ; NSM
AAC1          ; NSM
AAEC..AAED    ; NSM
AAF6          ; NSM
ABE5          ; NSM
ABE8          ; NSM
ABED          ; NSM
FB1E          ; NSM
FE00..FE0F    ; NSM
FE20..FE2F    ; NSM
101FD         ; NSM
102E0         ; NSM
10376..1037A  ; NSM
10A01..10A03  ; NSM
10A05..10A06  ; NSM
10A0C..10A0F  ; NSM
10A38..10A3A  ; NSM
10A3F         ; NSM
10AE5..10AE6  ; NSM
10D24..10D27  ; NSM
10D69..10D6D  ; NSM
10EAB..10EAC  ; NSM
10EFA..10EFF  ; NSM
10F46..10F50  ; NSM
10F82..10F85  ; NSM
11001         ; NSM
11038..11046  ; NSM
11070         ; NSM
11073..11074  ; NSM
1107F..11081  ; NSM
110B3..110B6  ; NSM
110B9..110BA  ; NSM
110C2         ; NSM
11100..11102  ; NSM
11127..1112B  ; NSM
1112D..11134  ; NSM
11173         ; NSM
11180..11181  ; NSM
111B6..111BE  ; NSM
111C9..111CC  ; NSM
111CF         ; NSM
1122F..11231  ; NSM
11234         ; NSM
11236..11237  ; NSM
1123E         ; NSM
11241         ; NSM
112DF         ; NSM
112E3..112EA  ; NSM
11300..11301  ; NSM
1133B..1133C  ; NSM
11340         ; NSM
11366..1136C  ; NSM
11370..11374  ; NSM
113BB..113C0  ; NSM
113CE         ; NSM
113D0         ; NSM
113D2         ; NSM
113E1..113E2  ; NSM
11438..1143F  ; NSM
11442..11444  ; NSM
11446         ; NSM
1145E         ; NSM
114B3..114B8  ; NSM
114BA         ; NSM
114BF..114C0  ; NSM
114C2..114C3  ; NSM
115B2..115B5  ; NSM
115BC..115BD  ; NSM
115BF..115C0  ; NSM
115DC..115DD  ; NSM
11633..1163A  ; NSM
1163D         ; NSM
1163F..11640  ; NSM
116AB         ; NSM
116AD         ; NSM
116B0..116B5  ; NSM
116B7         ; NSM
1171D         ; NSM
1171F         ; NSM
11722..11725  ; NSM
11727..1172B  ; NSM
1182F..11837  ; NSM
11839..1183A  ; NSM
1193B..1193C  ; NSM
1193E         ; NSM
11943         ; NSM
119D4..119D7  ; NSM
119DA..119DB  ; NSM
119E0         ; NSM
11A01..11A06  ; NSM
11A09..11A0A  ; NSM
11A33..11A38  ; NSM
11A3B..11A3E  ; NSM
11A47         ; NSM
11A51..11A56  ; NSM
11A59..11A5B  ; NSM
11A8A..11A96  ; NSM
11A98..11A99  ; NSM
11B60         ; NSM
11B62..11B64  ; NSM
11B66         ; NSM
11C30..11C36  ; NSM
11C38..11C3D  ; NSM
11C92..11CA7  ; NSM
11CAA..11CB0  ; NSM
11CB2..11CB3  ; NSM
11CB5..11CB6  ; NSM
11D31..11D36  ; NSM
11D3A         ; NSM
11D3C..11D3D  ; NSM
11D3F..11D45  ; NSM
11D47         ; NSM
11D90..11D91  ; NSM
11D95         ; NSM
11D97         ; NSM
11EF3..11EF4  ; NSM
11F00..11F01  ; NSM
11F36..11F3A  ; NSM
11F40         ; NSM
11F42         ; NSM
11F5A         ; NSM
13440         ; NSM
13447..13455  ; NSM
1611E..16129  ; NSM
1612D..1612F  ; NSM
16AF0..16AF4  ; NSM
16B30..16B36  ; NSM
16F4F         ; NSM
16F8F..16F92  ; NSM
16FE4         ; NSM
1BC9D..1BC9E  ; NSM
1CF00..1CF2D  ; NSM
1CF30..1CF46  ; NSM
1D167..1D169  ; NSM
1D17B..1D182  ; NSM
1D185..1D18B  ; NSM
1D1AA..1D1AD  ; NSM
1D242..1D244  ; NSM
1DA00..1DA36  ; NSM
1DA3B..1DA6C  ; NSM
1DA75         ; NSM
1DA84         ; NSM
1DA9B..1DA9F  ; NSM
1DAA1..1DAAF  ; NSM
1E000..1E006  ; NSM
1E008..1E018  ; NSM
1E01B..1E021  ; NSM
1E023..1E024  ; NSM
1E026..1E02A  ; NSM
1E08F         ; NSM
1E130..1E136  ; NSM
1E2AE         ; NSM
1E2EC..1E2EF  ; NSM
1E4EC..1E4EF  ; NSM
1E5EE..1E5EF  ; NSM
1E6E3         ; NSM
1E6E6         ; NSM
1E6EE..1E6EF  ; NSM
1E6F5         ; NSM
1E8D0..1E8D6  ; NSM
1E944..1E94A  ; NSM
E0100..E01EF  ; NSM
0608          ; AL
060B          ; AL
060D          ; AL
061B          ; AL
061C          ; AL
061D..061F    ; AL
0620..063F    ; AL
0640          ; AL
0641..064A    ; AL
066D          ; AL
066E..066F    ; AL
0671..06D3    ; AL
06D4          ; AL
06D5          ; AL
06E5..06E6    ; AL
06EE..06EF    ; AL
06FA..06FC    ; AL
06FD..06FE    ; AL
06FF          ; AL
0700..070D    ; AL
070F          ; AL
0710          ; AL
0712..072F    ; AL
074D..07A5    ; AL
07B1          ; AL
0860..086A    ; AL
0870..0887    ; AL
0888          ; AL
0889..088F    ; AL
08A0..08C8    ; AL
08C9          ; AL
FB50..FBB1    ; AL
FBB2..FBC2    ; AL
FBD3..FD3D    ; AL
FD50..FD8F    ; AL
FD92..FDC7    ; AL
FDF0..FDFB    ; AL
FDFC          ; AL
FE70..FE74    ; AL
FE76..FEFC    ; AL
10D00..10D23  ; AL
10EC2..10EC4  ; AL
10EC5         ; AL
10EC6..10EC7  ; AL
10F30..10F45  ; AL
10F51..10F54  ; AL
10F55..10F59  ; AL
1EC71..1ECAB  ; AL
1ECAC         ; AL
1ECAD..1ECAF  ; AL
1ECB0         ; AL
1ECB1..1ECB4  ; AL
1ED01..1ED2D  ; AL
1ED2E         ; AL
1ED2F..1ED3D  ; AL
1EE00..1EE03  ; AL
1EE05..1EE1F  ; AL
1EE21..1EE22  ; AL
1EE24         ; AL
1EE27         ; AL
1EE29..1EE32  ; AL
1EE34..1EE37  ; AL
1EE39         ; AL
1EE3B         ; AL
1EE42         ; AL
1EE47         ; AL
1EE49         ; AL
1EE4B         ; AL
1EE4D..1EE4F  ; AL
1EE51..1EE52  ; AL
1EE54         ; AL
1EE57         ; AL
1EE59         ; AL
1EE5B         ; AL
1EE5D         ; AL
1EE5F         ; AL
1EE61..1EE62  ; AL
1EE64         ; AL
1EE67..1EE6A  ; AL
1EE6C..1EE72  ; AL
1EE74..1EE77  ; AL
1EE79..1EE7C  ; AL
1EE7E         ; AL
1EE80..1EE89  ; AL
1EE8B..1EE9B  ; AL
1EEA1..1EEA3  ; AL
1EEA5..1EEA9  ; AL
1EEAB..1EEBB  ; AL
202D          ; LRO
202E          ; RLO
202A          ; LRE
202B          ; RLE
202C          ; PDF
2066          ; LRI
2067          ; RLI
2068          ; FSI
2069          ; PDI
)UCD";

// PropList.txt
static const char unicode17WhiteSpace[] = R"UCD(
0009..000D    ; White_Space
0020          ; White_Space
0085          ; White_Space
00A0          ; White_Space
1680          ; White_Space
2000..200A    ; White_Space
2028          ; White_Space
2029          ; White_Space
202F          ; White_Space
205F          ; White_Space
3000          ; White_Space
)UCD";

// DerivedCoreProperties.txt
static const char unicode17DefaultIgnorable[] = R"UCD(
00AD          ; Default_Ignorable_Code_Point
034F          ; Default_Ignorable_Code_Point
061C          ; Default_Ignorable_Code_Point
115F..1160    ; Default_Ignorable_Code_Point
17B4..17B5    ; Default_Ignorable_Code_Point
180B..180D    ; Default_Ignorable_Code_Point
180E          ; Default_Ignorable_Code_Point
180F          ; Default_Ignorable_Code_Point
200B..200F    ; Default_Ignorable_Code_Point
202A..202E    ; Default_Ignorable_Code_Point
2060..2064    ; Default_Ignorable_Code_Point
2065          ; Default_Ignorable_Code_Point
2066..206F    ; Default_Ignorable_Code_Point
3164          ; Default_Ignorable_Code_Point
FE00..FE0F    ; Default_Ignorable_Code_Point
FEFF          ; Default_Ignorable_Code_Point
FFA0          ; Default_Ignorable_Code_Point
FFF0..FFF8    ; Default_Ignorable_Code_Point
1BCA0..1BCA3  ; Default_Ignorable_Code_Point
1D173..1D17A  ; Default_Ignorable_Code_Point
E0000         ; Default_Ignorable_Code_Point
E0001         ; Default_Ignorable_Code_Point
E0002..E001F  ; Default_Ignorable_Code_Point
E0020..E007F  ; Default_Ignorable_Code_Point
E0080..E00FF  ; Default_Ignorable_Code_Point
E0100..E01EF  ; Default_Ignorable_Code_Point
E01F0..E0FFF  ; Default_Ignorable_Code_Point
)UCD";

// GraphemeBreakProperty.txt
static const char unicode17GraphemeBreak[] = R"UCD(
0600..0605    ; Prepend
06DD          ; Prepend
070F          ; Prepend
0890..0891    ; Prepend
08E2          ; Prepend
0D4E          ; Prepend
110BD         ; Prepend
110CD         ; Prepend
111C2..111C3  ; Prepend
113D1         ; Prepend
1193F         ; Prepend
11941         ; Prepend
11A84..11A89  ; Prepend
11D46         ; Prepend
11F02         ; Prepend
000D          ; CR
000A          ; LF
0000..0009    ; Control
000B..000C    ; Control
000E..001F    ; Control
007F..009F    ; Control
00AD          ; Control
061C          ; Control
180E          ; Control
200B          ; Control
200E..200F    ; Control
2028          ; Control
2029          ; Control
202A..202E    ; Control
2060..2064    ; Control
2065          ; Control
2066..206F    ; Control
FEFF          ; Control
FFF0..FFF8    ; Control
FFF9..FFFB    ; Control
13430..1343F  ; Control
1BCA0..1BCA3  ; Control
1D173..1D17A  ; Control
E0000         ; Control
E0001         ; Control
E0002..E001F  ; Control
E0080..E00FF  ; Control
E01F0..E0FFF  ; Control
0300..036F    ; Extend
0483..0487    ; Extend
0488..0489    ; Extend
0591..05BD    ; Extend
05BF          ; Extend
05C1..05C2    ; Extend
05C4..05C5    ; Extend
05C7          ; Extend
0610..061A    ; Extend
064B..065F    ; Extend
0670          ; Extend
06D6..06DC    ; Extend
06DF..06E4    ; Extend
06E7..06E8    ; Extend
06EA..06ED    ; Extend
0711          ; Extend
0730..074A    ; Extend
07A6..07B0    ; Extend
07EB..07F3    ; Extend
07FD          ; Extend
0816..0819    ; Extend
081B..0823    ; Extend
0825..0827    ; Extend
0829..082D    ; Extend
0859..085B    ; Extend
0897..089F    ; Extend
08CA..08E1    ; Extend
08E3..0902    ; Extend
093A          ; Extend
093C          ; Extend
0941..0948    ; Extend
094D          ; Extend
0951..0957    ; Extend
0962..0963    ; Extend
0981          ; Extend
09BC          ; Extend
09BE          ; Extend
09C1..09C4    ; Extend
09CD          ; Extend
09D7          ; Extend
09E2..09E3    ; Extend
09FE          ; Extend
0A01..0A02    ; Extend
0A3C          ; Extend
0A41..0A42    ; Extend
0A47..0A48    ; Extend
0A4B..0A4D    ; Extend
0A51          ; Extend
0A70..0A71    ; Extend
0A75          ; Extend
0A81..0A82    ; Extend
0ABC          ; Extend
0AC1..0AC5    ; Extend
0AC7..0AC8    ; Extend
0ACD          ; Extend
0AE2..0AE3    ; Extend
0AFA..0AFF    ; Extend
0B01          ; Extend
0B3C          ; Extend
0B3E          ; Extend
0B3F          ; Extend
0B41..0B44    ; Extend
0B4D          ; Extend
0B55..0B56    ; Extend
0B57          ; Extend
0B62..0B63    ; Extend
0B82          ; Extend
0BBE          ; Extend
0BC0          ; Extend
0BCD          ; Extend
0BD7          ; Extend
0C00          ; Extend
0C04          ; Extend
0C3C          ; Extend
0C3E..0C40    ; Extend
0C46..0C48    ; Extend
0C4A..0C4D    ; Extend
0C55..0C56    ; Extend
0C62..0C63    ; Extend
0C81          ; Extend
0CBC          ; Extend
0CBF          ; Extend
0CC0          ; Extend
0CC2          ; Extend
0CC6          ; Extend
0CC7..0CC8    ; Extend
0CCA..0CCB    ; Extend
0CCC..0CCD    ; Extend
0CD5..0CD6    ; Extend
0CE2..0CE3    ; Extend
0D00..0D01    ; Extend
0D3B..0D3C    ; Extend
0D3E          ; Extend
0D41..0D44    ; Extend
0D4D          ; Extend
0D57          ; Extend
0D62..0D63    ; Extend
0D81          ; Extend
0DCA          ; Extend
0DCF          ; Extend
0DD2..0DD4    ; Extend
0DD6          ; Extend
0DDF          ; Extend
0E31          ; Extend
0E34..0E3A    ; Extend
0E47..0E4E    ; Extend
0EB1          ; Extend
0EB4..0EBC    ; Extend
0EC8..0ECE    ; Extend
0F18..0F19    ; Extend
0F35          ; Extend
0F37          ; Extend
0F39          ; Extend
0F71..0F7E    ; Extend
0F80..0F84    ; Extend
0F86..0F87    ; Extend
0F8D..0F97    ; Extend
0F99..0FBC    ; Extend
0FC6          ; Extend
102D..1030    ; Extend
1032..1037    ; Extend
1039..103A    ; Extend
103D..103E    ; Extend
1058..1059    ; Extend
105E..1060    ; Extend
1071..1074    ; Extend
1082          ; Extend
1085..1086    ; Extend
108D          ; Extend
109D          ; Extend
135D..135F    ; Extend
1712..1714    ; Extend
1715          ; Extend
1732..1733    ; Extend
1734          ; Extend
1752..1753    ; Extend
1772..1773    ; Extend
17B4..17B5    ; Extend
17B7..17BD    ; Extend
17C6          ; Extend
17C9..17D3    ; Extend
17DD          ; Extend
180B..180D    ; Extend
180F          ; Extend
1885..1886    ; Extend
18A9          ; Extend
1920..1922    ; Extend
1927..1928    ; Extend
1932          ; Extend
1939..193B    ; Extend
1A17..1A18    ; Extend
1A1B          ; Extend
1A56          ; Extend
1A58..1A5E    ; Extend
1A60          ; Extend
1A62          ; Extend
1A65..1A6C    ; Extend
1A73..1A7C    ; Extend
1A7F          ; Extend
1AB0..1ABD    ; Extend
1ABE          ; Extend
1ABF..1ADD    ; Extend
1AE0..1AEB    ; Extend
1B00..1B03    ; Extend
1B34          ; Extend
1B35          ; Extend
1B36..1B3A    ; Extend
1B3B          ; Extend
1B3C          ; Extend
1B3D          ; Extend
1B42          ; Extend
1B43..1B44    ; Extend
1B6B..1B73    ; Extend
1B80..1B81    ; Extend
1BA2..1BA5    ; Extend
1BA8..1BA9    ; Extend
1BAA          ; Extend
1BAB..1BAD    ; Extend
1BE6          ; Extend
1BE8..1BE9    ; Extend
1BED          ; Extend
1BEF..1BF1    ; Extend
1BF2..1BF3    ; Extend
1C2C..1C33    ; Extend
1C36..1C37    ; Extend
1CD0..1CD2    ; Extend
1CD4..1CE0    ; Extend
1CE2..1CE8    ; Extend
1CED          ; Extend
1CF4          ; Extend
1CF8..1CF9    ; Extend
1DC0..1DFF    ; Extend
200C          ; Extend
20D0..20DC    ; Extend
20DD..20E0    ; Extend
20E1          ; Extend
20E2..20E4    ; Extend
20E5..20F0    ; Extend
2CEF..2CF1    ; Extend
2D7F          ; Extend
2DE0..2DFF    ; Extend
302A..302D    ; Extend
302E..302F    ; Extend
3099..309A    ; Extend
A66F          ; Extend
A670..A672    ; Extend
A674..A67D    ; Extend
A69E..A69F    ; Extend
A6F0..A6F1    ; Extend
A802          ; Extend
A806          ; Extend
A80B          ; Extend
A825..A826    ; Extend
A82C          ; Extend
A8C4..A8C5    ; Extend
A8E0..A8F1    ; Extend
A8FF          ; Extend
A926..A92D    ; Extend
A947..A951    ; Extend
A953          ; Extend
A980..A982    ; Extend
A9B3          ; Extend
A9B6..A9B9    ; Extend
A9BC..A9BD    ; Extend
A9C0          ; Extend
A9E5          ; Extend
AA29..AA2E    ; Extend
AA31..AA32    ; Extend
AA35..AA36    ; Extend
AA43          ; Extend
AA4C          ; Extend
AA7C          ; Extend
AAB0          ; Extend
AAB2..AAB4    ; Extend
AAB7..AAB8    ; Extend
AABE..AABF    ; Extend
AAC1          ; Extend
AAEC..AAED    ; Extend
AAF6          ; Extend
ABE5          ; Extend
ABE8          ; Extend
ABED          ; Extend
FB1E          ; Extend
FE00..FE0F    ; Extend
FE20..FE2F    ; Extend
FF9E..FF9F    ; Extend
101FD         ; Extend
102E0         ; Extend
10376..1037A  ; Extend
10A01..10A03  ; Extend
10A05..10A06  ; Extend
10A0C..10A0F  ; Extend
10A38..10A3A  ; Extend
10A3F         ; Extend
10AE5..10AE6  ; Extend
10D24..10D27  ; Extend
10D69..10D6D  ; Extend
10EAB..10EAC  ; Extend
10EFA..10EFF  ; Extend
10F46..10F50  ; Extend
10F82..10F85  ; Extend
11001         ; Extend
11038..11046  ; Extend
11070         ; Extend
11073..11074  ; Extend
1107F..11081  ; Extend
110B3..110B6  ; Extend
110B9..110BA  ; Extend
110C2         ; Extend
11100..11102  ; Extend
11127..1112B  ; Extend
1112D..11134  ; Extend
11173         ; Extend
11180..11181  ; Extend
111B6..111BE  ; Extend
111C0         ; Extend
111C9..111CC  ; Extend
111CF         ; Extend
1122F..11231  ; Extend
11234         ; Extend
11235         ; Extend
11236..11237  ; Extend
1123E         ; Extend
11241         ; Extend
112DF         ; Extend
112E3..112EA  ; Extend
11300..11301  ; Extend
1133B..1133C  ; Extend
1133E         ; Extend
11340         ; Extend
1134D         ; Extend
11357         ; Extend
11366..1136C  ; Extend
11370..11374  ; Extend
113B8         ; Extend
113BB..113C0  ; Extend
113C2         ; Extend
113C5         ; Extend
113C7..113C9  ; Extend
113CE         ; Extend
113CF         ; Extend
113D0         ; Extend
113D2         ; Extend
113E1..113E2  ; Extend
11438..1143F  ; Extend
11442..11444  ; Extend
11446         ; Extend
1145E         ; Extend
114B0         ; Extend
114B3..114B8  ; Extend
114BA         ; Extend
114BD         ; Extend
114BF..114C0  ; Extend
114C2..114C3  ; Extend
115AF         ; Extend
115B2..115B5  ; Extend
115BC..115BD  ; Extend
115BF..115C0  ; Extend
115DC..115DD  ; Extend
11633..1163A  ; Extend
1163D         ; Extend
1163F..11640  ; Extend
116AB         ; Extend
116AD         ; Extend
116B0..116B5  ; Extend
116B6         ; Extend
116B7         ; Extend
1171D         ; Extend
1171F         ; Extend
11722..11725  ; Extend
11727..1172B  ; Extend
1182F..11837  ; Extend
11839..1183A  ; Extend
11930         ; Extend
1193B..1193C  ; Extend
1193D         ; Extend
1193E         ; Extend
11943         ; Extend
119D4..119D7  ; Extend
119DA..119DB  ; Extend
119E0         ; Extend
11A01..11A0A  ; Extend
11A33..11A38  ; Extend
11A3B..11A3E  ; Extend
11A47         ; Extend
11A51..11A56  ; Extend
11A59..11A5B  ; Extend
11A8A..11A96  ; Extend
11A98..11A99  ; Extend
11B60         ; Extend
11B62..11B64  ; Extend
11B66         ; Extend
11C30..11C36  ; Extend
11C38..11C3D  ; Extend
11C3F         ; Extend
11C92..11CA7  ; Extend
11CAA..11CB0  ; Extend
11CB2..11CB3  ; Extend
11CB5..11CB6  ; Extend
11D31..11D36  ; Extend
11D3A         ; Extend
11D3C..11D3D  ; Extend
11D3F..11D45  ; Extend
11D47         ; Extend
11D90..11D91  ; Extend
11D95         ; Extend
11D97         ; Extend
11EF3..11EF4  ; Extend
11F00..11F01  ; Extend
11F36..11F3A  ; Extend
11F40         ; Extend
11F41         ; Extend
11F42         ; Extend
11F5A         ; Extend
13440         ; Extend
13447..13455  ; Extend
1611E..16129  ; Extend
1612D..1612F  ; Extend
16AF0..16AF4  ; Extend
16B30..16B36  ; Extend
16F4F         ; Extend
16F8F..16F92  ; Extend
16FE4         ; Extend
16FF0..16FF1  ; Extend
1BC9D..1BC9E  ; Extend
1CF00..1CF2D  ; Extend
1CF30..1CF46  ; Extend
1D165..1D166  ; Extend
1D167..1D169  ; Extend
1D16D..1D172  ; Extend
1D17B..1D182  ; Extend
1D185..1D18B  ; Extend
1D1AA..1D1AD  ; Extend
1D242..1D244  ; Extend
1DA00..1DA36  ; Extend
1DA3B..1DA6C  ; Extend
1DA75         ; Extend
1DA84         ; Extend
1DA9B..1DA9F  ; Extend
1DAA1..1DAAF  ; Extend
1E000..1E006  ; Extend
1E008..1E018  ; Extend
1E01B..1E021  ; Extend
1E023..1E024  ; Extend
1E026..1E02A  ; Extend
1E08F         ; Extend
1E130..1E136  ; Extend
1E2AE         ; Extend
1E2EC..1E2EF  ; Extend
1E4EC..1E4EF  ; Extend
1E5EE..1E5EF  ; Extend
1E6E3         ; Extend
1E6E6         ; Extend
1E6EE..1E6EF  ; Extend
1E6F5         ; Extend
1E8D0..1E8D6  ; Extend
1E944..1E94A  ; Extend
1F3FB..1F3FF  ; Extend
E0020..E007F  ; Extend
E0100..E01EF  ; Extend
1F1E6..1F1FF  ; Regional_Indicator
0903          ; SpacingMark
093B          ; SpacingMark
093E..0940    ; SpacingMark
0949..094C    ; SpacingMark
094E..094F    ; SpacingMark
0982..0983    ; SpacingMark
09BF..09C0    ; SpacingMark
09C7..09C8    ; SpacingMark
09CB..09CC    ; SpacingMark
0A03          ; SpacingMark
0A3E..0A40    ; SpacingMark
0A83          ; SpacingMark
0ABE..0AC0    ; SpacingMark
0AC9          ; SpacingMark
0ACB..0ACC    ; SpacingMark
0B02..0B03    ; SpacingMark
0B40          ; SpacingMark
0B47..0B48    ; SpacingMark
0B4B..0B4C    ; SpacingMark
0BBF          ; SpacingMark
0BC1..0BC2    ; SpacingMark
0BC6..0BC8    ; SpacingMark
0BCA..0BCC    ; SpacingMark
0C01..0C03    ; SpacingMark
0C41..0C44    ; SpacingMark
0C82..0C83    ; SpacingMark
0CBE          ; SpacingMark
0CC1          ; SpacingMark
0CC3..0CC4    ; SpacingMark
0CF3          ; SpacingMark
0D02..0D03    ; SpacingMark
0D3F..0D40    ; SpacingMark
0D46..0D48    ; SpacingMark
0D4A..0D4C    ; SpacingMark
0D82..0D83    ; SpacingMark
0DD0..0DD1    ; SpacingMark
0DD8..0DDE    ; SpacingMark
0DF2..0DF3    ; SpacingMark
0E33          ; SpacingMark
0EB3          ; SpacingMark
0F3E..0F3F    ; SpacingMark
0F7F          ; SpacingMark
1031          ; SpacingMark
103B..103C    ; SpacingMark
1056..1057    ; SpacingMark
1084          ; SpacingMark
17B6          ; SpacingMark
17BE..17C5    ; SpacingMark
17C7..17C8    ; SpacingMark
1923..1926    ; SpacingMark
1929..192B    ; SpacingMark
1930..1931    ; SpacingMark
1933..1938    ; SpacingMark
1A19..1A1A    ; SpacingMark
1A55          ; SpacingMark
1A57          ; SpacingMark
1A6D..1A72    ; SpacingMark
1B04          ; SpacingMark
1B3E..1B41    ; SpacingMark
1B82          ; SpacingMark
1BA1          ; SpacingMark
1BA6..1BA7    ; SpacingMark
1BE7          ; SpacingMark
1BEA..1BEC    ; SpacingMark
1BEE          ; SpacingMark
1C24..1C2B    ; SpacingMark
1C34..1C35    ; SpacingMark
1CE1          ; SpacingMark
1CF7          ; SpacingMark
A823..A824    ; SpacingMark
A827          ; SpacingMark
A880..A881    ; SpacingMark
A8B4..A8C3    ; SpacingMark
A952          ; SpacingMark
A983          ; SpacingMark
A9B4..A9B5    ; SpacingMark
A9BA..A9BB    ; SpacingMark
A9BE..A9BF    ; SpacingMark
AA2F..AA30    ; SpacingMark
AA33..AA34    ; SpacingMark
AA4D          ; SpacingMark
AAEB          ; SpacingMark
AAEE..AAEF    ; SpacingMark
AAF5          ; SpacingMark
ABE3..ABE4    ; SpacingMark
ABE6..ABE7    ; SpacingMark
ABE9..ABEA    ; SpacingMark
ABEC          ; SpacingMark
11000         ; SpacingMark
11002         ; SpacingMark
11082         ; SpacingMark
110B0..110B2  ; SpacingMark
110B7..110B8  ; SpacingMark
1112C         ; SpacingMark
11145..11146  ; SpacingMark
11182         ; SpacingMark
111B3..111B5  ; SpacingMark
111BF         ; SpacingMark
111CE         ; SpacingMark
1122C..1122E  ; SpacingMark
11232..11233  ; SpacingMark
112E0..112E2  ; SpacingMark
11302..11303  ; SpacingMark
1133F         ; SpacingMark
11341..11344  ; SpacingMark
11347..11348  ; SpacingMark
1134B..1134C  ; SpacingMark
11362..11363  ; SpacingMark
113B9..113BA  ; SpacingMark
113CA         ; SpacingMark
113CC..113CD  ; SpacingMark
11435..11437  ; SpacingMark
11440..11441  ; SpacingMark
11445         ; SpacingMark
114B1..114B2  ; SpacingMark
114B9         ; SpacingMark
114BB..114BC  ; SpacingMark
114BE         ; SpacingMark
114C1         ; SpacingMark
115B0..115B1  ; SpacingMark
115B8..115BB  ; SpacingMark
115BE         ; SpacingMark
11630..11632  ; SpacingMark
1163B..1163C  ; SpacingMark
1163E         ; SpacingMark
116AC         ; SpacingMark
116AE..116AF  ; SpacingMark
1171E         ; SpacingMark
11726         ; SpacingMark
1182C..1182E  ; SpacingMark
11838         ; SpacingMark
11931..11935  ; SpacingMark
11937..11938  ; SpacingMark
11940         ; SpacingMark
11942         ; SpacingMark
119D1..119D3  ; SpacingMark
119DC..119DF  ; SpacingMark
119E4         ; SpacingMark
11A39         ; SpacingMark
11A57..11A58  ; SpacingMark
11A97         ; SpacingMark
11B61         ; SpacingMark
11B65         ; SpacingMark
11B67         ; SpacingMark
11C2F         ; SpacingMark
11C3E         ; SpacingMark
11CA9         ; SpacingMark
11CB1         ; SpacingMark
11CB4         ; SpacingMark
11D8A..11D8E  ; SpacingMark
11D93..11D94  ; SpacingMark
11D96         ; SpacingMark
11EF5..11EF6  ; SpacingMark
11F03         ; SpacingMark
11F34..11F35  ; SpacingMark
11F3E..11F3F  ; SpacingMark
1612A..1612C  ; SpacingMark
16F51..16F87  ; SpacingMark
1100..115F    ; L
A960..A97C    ; L
1160..11A7    ; V
D7B0..D7C6    ; V
16D63         ; V
16D67..16D6A  ; V
11A8..11FF    ; T
D7CB..D7FB    ; T
AC00          ; LV
AC1C          ; LV
AC38          ; LV
AC54          ; LV
AC70          ; LV
AC8C          ; LV
ACA8          ; LV
ACC4          ; LV
ACE0          ; LV
ACFC          ; LV
AD18          ; LV
AD34          ; LV
AD50          ; LV
AD6C          ; LV
AD88          ; LV
ADA4          ; LV
ADC0          ; LV
ADDC          ; LV
ADF8          ; LV
AE14          ; LV
AE30          ; LV
AE4C          ; LV
AE68          ; LV
AE84          ; LV
AEA0          ; LV
AEBC          ; LV
AED8          ; LV
AEF4          ; LV
AF10          ; LV
AF2C          ; LV
AF48          ; LV
AF64          ; LV
AF80          ; LV
AF9C          ; LV
AFB8          ; LV
AFD4          ; LV
AFF0          ; LV
B00C          ; LV
B028          ; LV
B044          ; LV
B060          ; LV
B07C          ; LV
B098          ; LV
B0B4          ; LV
B0D0          ; LV
B0EC          ; LV
B108          ; LV
B124          ; LV
B140          ; LV
B15C          ; LV
B178          ; LV
B194          ; LV
B1B0          ; LV
B1CC          ; LV
B1E8          ; LV
B204          ; LV
B220          ; LV
B23C          ; LV
B258          ; LV
B274          ; LV
B290          ; LV
B2AC          ; LV
B2C8          ; LV
B2E4          ; LV
B300          ; LV
B31C          ; LV
B338          ; LV
B354          ; LV
B370          ; LV
B38C          ; LV
B3A8          ; LV
B3C4          ; LV
B3E0          ; LV
B3FC          ; LV
B418          ; LV
B434          ; LV
B450          ; LV
B46C          ; LV
B488          ; LV
B4A4          ; LV
B4C0          ; LV
B4DC          ; LV
B4F8          ; LV
B514          ; LV
B530          ; LV
B54C          ; LV
B568          ; LV
B584          ; LV
B5A0          ; LV
B5BC          ; LV
B5D8          ; LV
B5F4          ; LV
B610          ; LV
B62C          ; LV
B648          ; LV
B664          ; LV
B680          ; LV
B69C          ; LV
B6B8          ; LV
B6D4          ; LV
B6F0          ; LV
B70C          ; LV
B728          ; LV
B744          ; LV
B760          ; LV
B77C          ; LV
B798          ; LV
B7B4          ; LV
B7D0          ; LV
B7EC          ; LV
B808          ; LV
B824          ; LV
B840          ; LV
B85C          ; LV
B878          ; LV
B894          ; LV
B8B0          ; LV
B8CC          ; LV
B8E8          ; LV
B904          ; LV
B920          ; LV
B93C          ; LV
B958          ; LV
B974          ; LV
B990          ; LV
B9AC          ; LV
B9C8          ; LV
B9E4          ; LV
BA00          ; LV
BA1C          ; LV
BA38          ; LV
BA54          ; LV
BA70          ; LV
BA8C          ; LV
BAA8          ; LV
BAC4          ; LV
BAE0          ; LV
BAFC          ; LV
BB18          ; LV
BB34          ; LV
BB50          ; LV
BB6C          ; LV
BB88          ; LV
BBA4          ; LV
BBC0          ; LV
BBDC          ; LV
BBF8          ; LV
BC14          ; LV
BC30          ; LV
BC4C          ; LV
BC68          ; LV
BC84          ; LV
BCA0          ; LV
BCBC          ; LV
BCD8          ; LV
BCF4          ; LV
BD10          ; LV
BD2C          ; LV
BD48          ; LV
BD64          ; LV
BD80          ; LV
BD9C          ; LV
BDB8          ; LV
BDD4          ; LV
BDF0          ; LV
BE0C          ; LV
BE28          ; LV
BE44          ; LV
BE60          ; LV
BE7C          ; LV
BE98          ; LV
BEB4          ; LV
BED0          ; LV
BEEC          ; LV
BF08          ; LV
BF24          ; LV
BF40          ; LV
BF5C          ; LV
BF78          ; LV
BF94          ; LV
BFB0          ; LV
BFCC          ; LV
BFE8          ; LV
C004          ; LV
C020          ; LV
C03C          ; LV
C058          ; LV
C074          ; LV
C090          ; LV
C0AC          ; LV
C0C8          ; LV
C0E4          ; LV
C100          ; LV
C11C          ; LV
C138          ; LV
C154          ; LV
C170          ; LV
C18C          ; LV
C1A8          ; LV
C1C4          ; LV
C1E0          ; LV
C1FC          ; LV
C218          ; LV
C234          ; LV
C250          ; LV
C26C          ; LV
C288          ; LV
C2A4          ; LV
C2C0          ; LV
C2DC          ; LV
C2F8          ; LV
C314          ; LV
C330          ; LV
C34C          ; LV
C368          ; LV
C384          ; LV
C3A0          ; LV
C3BC          ; LV
C3D8          ; LV
C3F4          ; LV
C410          ; LV
C42C          ; LV
C448          ; LV
C464          ; LV
C480          ; LV
C49C          ; LV
C4B8          ; LV
C4D4          ; LV
C4F0          ; LV
C50C          ; LV
C528          ; LV
C544          ; LV
C560          ; LV
C57C          ; LV
C598          ; LV
C5B4          ; LV
C5D0          ; LV
C5EC          ; LV
C608          ; LV
C624          ; LV
C640          ; LV
C65C          ; LV
C678          ; LV
C694          ; LV
C6B0          ; LV
C6CC          ; LV
C6E8          ; LV
C704          ; LV
C720          ; LV
C73C          ; LV
C758          ; LV
C774          ; LV
C790          ; LV
C7AC          ; LV
C7C8          ; LV
C7E4          ; LV
C800          ; LV
C81C          ; LV
C838          ; LV
C854          ; LV
C870          ; LV
C88C          ; LV
C8A8          ; LV
C8C4          ; LV
C8E0          ; LV
C8FC          ; LV
C918          ; LV
C934          ; LV
C950          ; LV
C96C          ; LV
C988          ; LV
C9A4          ; LV
C9C0          ; LV
C9DC          ; LV
C9F8          ; LV
CA14          ; LV
CA30          ; LV
CA4C          ; LV
CA68          ; LV
CA84          ; LV
CAA0          ; LV
CABC          ; LV
CAD8          ; LV
CAF4          ; LV
CB10          ; LV
CB2C          ; LV
CB48          ; LV
CB64          ; LV
CB80          ; LV
CB9C          ; LV
CBB8          ; LV
CBD4          ; LV
CBF0          ; LV
CC0C          ; LV
CC28          ; LV
CC44          ; LV
CC60          ; LV
CC7C          ; LV
CC98          ; LV
CCB4          ; LV
CCD0          ; LV
CCEC          ; LV
CD08          ; LV
CD24          ; LV
CD40          ; LV
CD5C          ; LV
CD78          ; LV
CD94          ; LV
CDB0          ; LV
CDCC          ; LV
CDE8          ; LV
CE04          ; LV
CE20          ; LV
CE3C          ; LV
CE58          ; LV
CE74          ; LV
CE90          ; LV
CEAC          ; LV
CEC8          ; LV
CEE4          ; LV
CF00          ; LV
CF1C          ; LV
CF38          ; LV
CF54          ; LV
CF70          ; LV
CF8C          ; LV
CFA8          ; LV
CFC4          ; LV
CFE0          ; LV
CFFC          ; LV
D018          ; LV
D034          ; LV
D050          ; LV
D06C          ; LV
D088          ; LV
D0A4          ; LV
D0C0          ; LV
D0DC          ; LV
D0F8          ; LV
D114          ; LV
D130          ; LV
D14C          ; LV
D168          ; LV
D184          ; LV
D1A0          ; LV
D1BC          ; LV
D1D8          ; LV
D1F4          ; LV
D210          ; LV
D22C          ; LV
D248          ; LV
D264          ; LV
D280          ; LV
D29C          ; LV
D2B8          ; LV
D2D4          ; LV
D2F0          ; LV
D30C          ; LV
D328          ; LV
D344          ; LV
D360          ; LV
D37C          ; LV
D398          ; LV
D3B4          ; LV
D3D0          ; LV
D3EC          ; LV
D408          ; LV
D424          ; LV
D440          ; LV
D45C          ; LV
D478          ; LV
D494          ; LV
D4B0          ; LV
D4CC          ; LV
D4E8          ; LV
D504          ; LV
D520          ; LV
D53C          ; LV
D558          ; LV
D574          ; LV
D590          ; LV
D5AC          ; LV
D5C8          ; LV
D5E4          ; LV
D600          ; LV
D61C          ; LV
D638          ; LV
D654          ; LV
D670          ; LV
D68C          ; LV
D6A8          ; LV
D6C4          ; LV
D6E0          ; LV
D6FC          ; LV
D718          ; LV
D734          ; LV
D750          ; LV
D76C          ; LV
D788          ; LV
AC01..AC1B    ; LVT
AC1D..AC37    ; LVT
AC39..AC53    ; LVT
AC55..AC6F    ; LVT
AC71..AC8B    ; LVT
AC8D..ACA7    ; LVT
ACA9..ACC3    ; LVT
ACC5..ACDF    ; LVT
ACE1..ACFB    ; LVT
ACFD..AD17    ; LVT
AD19..AD33    ; LVT
AD35..AD4F    ; LVT
AD51..AD6B    ; LVT
AD6D..AD87    ; LVT
AD89..ADA3    ; LVT
ADA5..ADBF    ; LVT
ADC1..ADDB    ; LVT
ADDD..ADF7    ; LVT
ADF9..AE13    ; LVT
AE15..AE2F    ; LVT
AE31..AE4B    ; LVT
AE4D..AE67    ; LVT
AE69..AE83    ; LVT
AE85..AE9F    ; LVT
AEA1..AEBB    ; LVT
AEBD..AED7    ; LVT
AED9..AEF3    ; LVT
AEF5..AF0F    ; LVT
AF11..AF2B    ; LVT
AF2D..AF47    ; LVT
AF49..AF63    ; LVT
AF65..AF7F    ; LVT
AF81..AF9B    ; LVT
AF9D..AFB7    ; LVT
AFB9..AFD3    ; LVT
AFD5..AFEF    ; LVT
AFF1..B00B    ; LVT
B00D..B027    ; LVT
B029..B043    ; LVT
B045..B05F    ; LVT
B061..B07B    ; LVT
B07D..B097    ; LVT
B099..B0B3    ; LVT
B0B5..B0CF    ; LVT
B0D1..B0EB    ; LVT
B0ED..B107    ; LVT
B109..B123    ; LVT
B125..B13F    ; LVT
B141..B15B    ; LVT
B15D..B177    ; LVT
B179..B193    ; LVT
B195..B1AF    ; LVT
B1B1..B1CB    ; LVT
B1CD..B1E7    ; LVT
B1E9..B203    ; LVT
B205..B21F    ; LVT
B221..B23B    ; LVT
B23D..B257    ; LVT
B259..B273    ; LVT
B275..B28F    ; LVT
B291..B2AB    ; LVT
B2AD..B2C7    ; LVT
B2C9..B2E3    ; LVT
B2E5..B2FF    ; LVT
B301..B31B    ; LVT
B31D..B337    ; LVT
B339..B353    ; LVT
B355..B36F    ; LVT
B371..B38B    ; LVT
B38D..B3A7    ; LVT
B3A9..B3C3    ; LVT
B3C5..B3DF    ; LVT
B3E1..B3FB    ; LVT
B3FD..B417    ; LVT
B419..B433    ; LVT
B435..B44F    ; LVT
B451..B46B    ; LVT
B46D..B487    ; LVT
B489..B4A3    ; LVT
B4A5..B4BF    ; LVT
B4C1..B4DB    ; LVT
B4DD..B4F7    ; LVT
B4F9..B513    ; LVT
B515..B52F    ; LVT
B531..B54B    ; LVT
B54D..B567    ; LVT
B569..B583    ; LVT
B585..B59F    ; LVT
B5A1..B5BB    ; LVT
B5BD..B5D7    ; LVT
B5D9..B5F3    ; LVT
B5F5..B60F    ; LVT
B611..B62B    ; LVT
B62D..B647    ; LVT
B649..B663    ; LVT
B665..B67F    ; LVT
B681..B69B    ; LVT
B69D..B6B7    ; LVT
B6B9..B6D3    ; LVT
B6D5..B6EF    ; LVT
B6F1..B70B    ; LVT
B70D..B727    ; LVT
B729..B743    ; LVT
B745..B75F    ; LVT
B761..B77B    ; LVT
B77D..B797    ; LVT
B799..B7B3    ; LVT
B7B5..B7CF    ; LVT
B7D1..B7EB    ; LVT
B7ED..B807    ; LVT
B809..B823    ; LVT
B825..B83F    ; LVT
B841..B85B    ; LVT
B85D..B877    ; LVT
B879..B893    ; LVT
B895..B8AF    ; LVT
B8B1..B8CB    ; LVT
B8CD..B8E7    ; LVT
B8E9..B903    ; LVT
B905..B91F    ; LVT
B921..B93B    ; LVT
B93D..B957    ; LVT
B959..B973    ; LVT
B975..B98F    ; LVT
B991..B9AB    ; LVT
B9AD..B9C7    ; LVT
B9C9..B9E3    ; LVT
B9E5..B9FF    ; LVT
BA01..BA1B    ; LVT
BA1D..BA37    ; LVT
BA39..BA53    ; LVT
BA55..BA6F    ; LVT
BA71..BA8B    ; LVT
BA8D..BAA7    ; LVT
BAA9..BAC3    ; LVT
BAC5..BADF    ; LVT
BAE1..BAFB    ; LVT
BAFD..BB17    ; LVT
BB19..BB33    ; LVT
BB35..BB4F    ; LVT
BB51..BB6B    ; LVT
BB6D..BB87    ; LVT
BB89..BBA3    ; LVT
BBA5..BBBF    ; LVT
BBC1..BBDB    ; LVT
BBDD..BBF7    ; LVT
BBF9..BC13    ; LVT
BC15..BC2F    ; LVT
BC31..BC4B    ; LVT
BC4D..BC67    ; LVT
BC69..BC83    ; LVT
BC85..BC9F    ; LVT
BCA1..BCBB    ; LVT
BCBD..BCD7    ; LVT
BCD9..BCF3    ; LVT
BCF5..BD0F    ; LVT
BD11..BD2B    ; LVT
BD2D..BD47    ; LVT
BD49..BD63    ; LVT
BD65..BD7F    ; LVT
BD81..BD9B    ; LVT
BD9D..BDB7    ; LVT
BDB9..BDD3    ; LVT
BDD5..BDEF    ; LVT
BDF1..BE0B    ; LVT
BE0D..BE27    ; LVT
BE29..BE43    ; LVT
BE45..BE5F    ; LVT
BE61..BE7B    ; LVT
BE7D..BE97    ; LVT
BE99..BEB3    ; LVT
BEB5..BECF    ; LVT
BED1..BEEB    ; LVT
BEED..BF07    ; LVT
BF09..BF23    ; LVT
BF25..BF3F    ; LVT
BF41..BF5B    ; LVT
BF5D..BF77    ; LVT
BF79..BF93    ; LVT
BF95..BFAF    ; LVT
BFB1..BFCB    ; LVT
BFCD..BFE7    ; LVT
BFE9..C003    ; LVT
C005..C01F    ; LVT
C021..C03B    ; LVT
C03D..C057    ; LVT
C059..C073    ; LVT
C075..C08F    ; LVT
C091..C0AB    ; LVT
C0AD..C0C7    ; LVT
C0C9..C0E3    ; LVT
C0E5..C0FF    ; LVT
C101..C11B    ; LVT
C11D..C137    ; LVT
C139..C153    ; LVT
C155..C16F    ; LVT
C171..C18B    ; LVT
C18D..C1A7    ; LVT
C1A9..C1C3    ; LVT
C1C5..C1DF    ; LVT
C1E1..C1FB    ; LVT
C1FD..C217    ; LVT
C219..C233    ; LVT
C235..C24F    ; LVT
C251..C26B    ; LVT
C26D..C287    ; LVT
C289..C2A3    ; LVT
C2A5..C2BF    ; LVT
C2C1..C2DB    ; LVT
C2DD..C2F7    ; LVT
C2F9..C313    ; LVT
C315..C32F    ; LVT
C331..C34B    ; LVT
C34D..C367    ; LVT
C369..C383    ; LVT
C385..C39F    ; LVT
C3A1..C3BB    ; LVT
C3BD..C3D7    ; LVT
C3D9..C3F3    ; LVT
C3F5..C40F    ; LVT
C411..C42B    ; LVT
C42D..C447    ; LVT
C449..C463    ; LVT
C465..C47F    ; LVT
C481..C49B    ; LVT
C49D..C4B7    ; LVT
C4B9..C4D3    ; LVT
C4D5..C4EF    ; LVT
C4F1..C50B    ; LVT
C50D..C527    ; LVT
C529..C543    ; LVT
C545..C55F    ; LVT
C561..C57B    ; LVT
C57D..C597    ; LVT
C599..C5B3    ; LVT
C5B5..C5CF    ; LVT
C5D1..C5EB    ; LVT
C5ED..C607    ; LVT
C609..C623    ; LVT
C625..C63F    ; LVT
C641..C65B    ; LVT
C65D..C677    ; LVT
C679..C693    ; LVT
C695..C6AF    ; LVT
C6B1..C6CB    ; LVT
C6CD..C6E7    ; LVT
C6E9..C703    ; LVT
C705..C71F    ; LVT
C721..C73B    ; LVT
C73D..C757    ; LVT
C759..C773    ; LVT
C775..C78F    ; LVT
C791..C7AB    ; LVT
C7AD..C7C7    ; LVT
C7C9..C7E3    ; LVT
C7E5..C7FF    ; LVT
C801..C81B    ; LVT
C81D..C837    ; LVT
C839..C853    ; LVT
C855..C86F    ; LVT
C871..C88B    ; LVT
C88D..C8A7    ; LVT
C8A9..C8C3    ; LVT
C8C5..C8DF    ; LVT
C8E1..C8FB    ; LVT
C8FD..C917    ; LVT
C919..C933    ; LVT
C935..C94F    ; LVT
C951..C96B    ; LVT
C96D..C987    ; LVT
C989..C9A3    ; LVT
C9A5..C9BF    ; LVT
C9C1..C9DB    ; LVT
C9DD..C9F7    ; LVT
C9F9..CA13    ; LVT
CA15..CA2F    ; LVT
CA31..CA4B    ; LVT
CA4D..CA67    ; LVT
CA69..CA83    ; LVT
CA85..CA9F    ; LVT
CAA1..CABB    ; LVT
CABD..CAD7    ; LVT
CAD9..CAF3    ; LVT
CAF5..CB0F    ; LVT
CB11..CB2B    ; LVT
CB2D..CB47    ; LVT
CB49..CB63    ; LVT
CB65..CB7F    ; LVT
CB81..CB9B    ; LVT
CB9D..CBB7    ; LVT
CBB9..CBD3    ; LVT
CBD5..CBEF    ; LVT
CBF1..CC0B    ; LVT
CC0D..CC27    ; LVT
CC29..CC43    ; LVT
CC45..CC5F    ; LVT
CC61..CC7B    ; LVT
CC7D..CC97    ; LVT
CC99..CCB3    ; LVT
CCB5..CCCF    ; LVT
CCD1..CCEB    ; LVT
CCED..CD07    ; LVT
CD09..CD23    ; LVT
CD25..CD3F    ; LVT
CD41..CD5B    ; LVT
CD5D..CD77    ; LVT
CD79..CD93    ; LVT
CD95..CDAF    ; LVT
CDB1..CDCB    ; LVT
CDCD..CDE7    ; LVT
CDE9..CE03    ; LVT
CE05..CE1F    ; LVT
CE21..CE3B    ; LVT
CE3D..CE57    ; LVT
CE59..CE73    ; LVT
CE75..CE8F    ; LVT
CE91..CEAB    ; LVT
CEAD..CEC7    ; LVT
CEC9..CEE3    ; LVT
CEE5..CEFF    ; LVT
CF01..CF1B    ; LVT
CF1D..CF37    ; LVT
CF39..CF53    ; LVT
CF55..CF6F    ; LVT
CF71..CF8B    ; LVT
CF8D..CFA7    ; LVT
CFA9..CFC3    ; LVT
CFC5..CFDF    ; LVT
CFE1..CFFB    ; LVT
CFFD..D017    ; LVT
D019..D033    ; LVT
D035..D04F    ; LVT
D051..D06B    ; LVT
D06D..D087    ; LVT
D089..D0A3    ; LVT
D0A5..D0BF    ; LVT
D0C1..D0DB    ; LVT
D0DD..D0F7    ; LVT
D0F9..D113    ; LVT
D115..D12F    ; LVT
D131..D14B    ; LVT
D14D..D167    ; LVT
D169..D183    ; LVT
D185..D19F    ; LVT
D1A1..D1BB    ; LVT
D1BD..D1D7    ; LVT
D1D9..D1F3    ; LVT
D1F5..D20F    ; LVT
D211..D22B    ; LVT
D22D..D247    ; LVT
D249..D263    ; LVT
D265..D27F    ; LVT
D281..D29B    ; LVT
D29D..D2B7    ; LVT
D2B9..D2D3    ; LVT
D2D5..D2EF    ; LVT
D2F1..D30B    ; LVT
D30D..D327    ; LVT
D329..D343    ; LVT
D345..D35F    ; LVT
D361..D37B    ; LVT
D37D..D397    ; LVT
D399..D3B3    ; LVT
D3B5..D3CF    ; LVT
D3D1..D3EB    ; LVT
D3ED..D407    ; LVT
D409..D423    ; LVT
D425..D43F    ; LVT
D441..D45B    ; LVT
D45D..D477    ; LVT
D479..D493    ; LVT
D495..D4AF    ; LVT
D4B1..D4CB    ; LVT
D4CD..D4E7    ; LVT
D4E9..D503    ; LVT
D505..D51F    ; LVT
D521..D53B    ; LVT
D53D..D557    ; LVT
D559..D573    ; LVT
D575..D58F    ; LVT
D591..D5AB    ; LVT
D5AD..D5C7    ; LVT
D5C9..D5E3    ; LVT
D5E5..D5FF    ; LVT
D601..D61B    ; LVT
D61D..D637    ; LVT
D639..D653    ; LVT
D655..D66F    ; LVT
D671..D68B    ; LVT
D68D..D6A7    ; LVT
D6A9..D6C3    ; LVT
D6C5..D6DF    ; LVT
D6E1..D6FB    ; LVT
D6FD..D717    ; LVT
D719..D733    ; LVT
D735..D74F    ; LVT
D751..D76B    ; LVT
D76D..D787    ; LVT
D789..D7A3    ; LVT
200D          ; ZWJ
)UCD";

// emoji-data.txt
static const char unicode17ExtendedPictographic[] = R"UCD(
00A9          ; Extended_Pictographic
00AE          ; Extended_Pictographic
203C          ; Extended_Pictographic
2049          ; Extended_Pictographic
2122          ; Extended_Pictographic
2139          ; Extended_Pictographic
2194..2199    ; Extended_Pictographic
21A9..21AA    ; Extended_Pictographic
231A..231B    ; Extended_Pictographic
2328          ; Extended_Pictographic
23CF          ; Extended_Pictographic
23E9..23EC    ; Extended_Pictographic
23ED..23EE    ; Extended_Pictographic
23EF          ; Extended_Pictographic
23F0          ; Extended_Pictographic
23F1..23F2    ; Extended_Pictographic
23F3          ; Extended_Pictographic
23F8..23FA    ; Extended_Pictographic
24C2          ; Extended_Pictographic
25AA..25AB    ; Extended_Pictographic
25B6          ; Extended_Pictographic
25C0          ; Extended_Pictographic
25FB..25FE    ; Extended_Pictographic
2600..2601    ; Extended_Pictographic
2602..2603    ; Extended_Pictographic
2604          ; Extended_Pictographic
260E          ; Extended_Pictographic
2611          ; Extended_Pictographic
2614..2615    ; Extended_Pictographic
2618          ; Extended_Pictographic
261D          ; Extended_Pictographic
2620          ; Extended_Pictographic
2622..2623    ; Extended_Pictographic
2626          ; Extended_Pictographic
262A          ; Extended_Pictographic
262E          ; Extended_Pictographic
262F          ; Extended_Pictographic
2638..2639    ; Extended_Pictographic
263A          ; Extended_Pictographic
2640          ; Extended_Pictographic
2642          ; Extended_Pictographic
2648..2653    ; Extended_Pictographic
265F          ; Extended_Pictographic
2660          ; Extended_Pictographic
2663          ; Extended_Pictographic
2665..2666    ; Extended_Pictographic
2668          ; Extended_Pictographic
267B          ; Extended_Pictographic
267E          ; Extended_Pictographic
267F          ; Extended_Pictographic
2692          ; Extended_Pictographic
2693          ; Extended_Pictographic
2694          ; Extended_Pictographic
2695          ; Extended_Pictographic
2696..2697    ; Extended_Pictographic
2699          ; Extended_Pictographic
269B..269C    ; Extended_Pictographic
26A0..26A1    ; Extended_Pictographic
26A7          ; Extended_Pictographic
26AA..26AB    ; Extended_Pictographic
26B0..26B1    ; Extended_Pictographic
26BD..26BE    ; Extended_Pictographic
26C4..26C5    ; Extended_Pictographic
26C8          ; Extended_Pictographic
26CE          ; Extended_Pictographic
26CF          ; Extended_Pictographic
26D1          ; Extended_Pictographic
26D3          ; Extended_Pictographic
26D4          ; Extended_Pictographic
26E9          ; Extended_Pictographic
26EA          ; Extended_Pictographic
26F0..26F1    ; Extended_Pictographic
26F2..26F3    ; Extended_Pictographic
26F4          ; Extended_Pictographic
26F5          ; Extended_Pictographic
26F7..26F9    ; Extended_Pictographic
26FA          ; Extended_Pictographic
26FD          ; Extended_Pictographic
2702          ; Extended_Pictographic
2705          ; Extended_Pictographic
2708..270C    ; Extended_Pictographic
270D          ; Extended_Pictographic
270F          ; Extended_Pictographic
2712          ; Extended_Pictographic
2714          ; Extended_Pictographic
2716          ; Extended_Pictographic
271D          ; Extended_Pictographic
2721          ; Extended_Pictographic
2728          ; Extended_Pictographic
2733..2734    ; Extended_Pictographic
2744          ; Extended_Pictographic
2747          ; Extended_Pictographic
274C          ; Extended_Pictographic
274E          ; Extended_Pictographic
2753..2755    ; Extended_Pictographic
2757          ; Extended_Pictographic
2763          ; Extended_Pictographic
2764          ; Extended_Pictographic
2795..2797    ; Extended_Pictographic
27A1          ; Extended_Pictographic
27B0          ; Extended_Pictographic
27BF          ; Extended_Pictographic
2934..2935    ; Extended_Pictographic
2B05..2B07    ; Extended_Pictographic
2B1B..2B1C    ; Extended_Pictographic
2B50          ; Extended_Pictographic
2B55          ; Extended_Pictographic
3030          ; Extended_Pictographic
303D          ; Extended_Pictographic
3297          ; Extended_Pictographic
3299          ; Extended_Pictographic
1F004         ; Extended_Pictographic
1F02C..1F02F  ; Extended_Pictographic
1F094..1F09F  ; Extended_Pictographic
1F0AF..1F0B0  ; Extended_Pictographic
1F0C0         ; Extended_Pictographic
1F0CF         ; Extended_Pictographic
1F0D0         ; Extended_Pictographic
1F0F6..1F0FF  ; Extended_Pictographic
1F170..1F171  ; Extended_Pictographic
1F17E..1F17F  ; Extended_Pictographic
1F18E         ; Extended_Pictographic
1F191..1F19A  ; Extended_Pictographic
1F1AE..1F1E5  ; Extended_Pictographic
1F201..1F202  ; Extended_Pictographic
1F203..1F20F  ; Extended_Pictographic
1F21A         ; Extended_Pictographic
1F22F         ; Extended_Pictographic
1F232..1F23A  ; Extended_Pictographic
1F23C..1F23F  ; Extended_Pictographic
1F249..1F24F  ; Extended_Pictographic
1F250..1F251  ; Extended_Pictographic
1F252..1F25F  ; Extended_Pictographic
1F266..1F2FF  ; Extended_Pictographic
1F300..1F30C  ; Extended_Pictographic
1F30D..1F30E  ; Extended_Pictographic
1F30F         ; Extended_Pictographic
1F310         ; Extended_Pictographic
1F311         ; Extended_Pictographic
1F312         ; Extended_Pictographic
1F313..1F315  ; Extended_Pictographic
1F316..1F318  ; Extended_Pictographic
1F319         ; Extended_Pictographic
1F31A         ; Extended_Pictographic
1F31B         ; Extended_Pictographic
1F31C         ; Extended_Pictographic
1F31D..1F31E  ; Extended_Pictographic
1F31F..1F320  ; Extended_Pictographic
1F321         ; Extended_Pictographic
1F324..1F32C  ; Extended_Pictographic
1F32D..1F32F  ; Extended_Pictographic
1F330..1F331  ; Extended_Pictographic
1F332..1F333  ; Extended_Pictographic
1F334..1F335  ; Extended_Pictographic
1F336         ; Extended_Pictographic
1F337..1F34A  ; Extended_Pictographic
1F34B         ; Extended_Pictographic
1F34C..1F34F  ; Extended_Pictographic
1F350         ; Extended_Pictographic
1F351..1F37B  ; Extended_Pictographic
1F37C         ; Extended_Pictographic
1F37D         ; Extended_Pictographic
1F37E..1F37F  ; Extended_Pictographic
1F380..1F393  ; Extended_Pictographic
1F396..1F397  ; Extended_Pictographic
1F399..1F39B  ; Extended_Pictographic
1F39E..1F39F  ; Extended_Pictographic
1F3A0..1F3C4  ; Extended_Pictographic
1F3C5         ; Extended_Pictographic
1F3C6         ; Extended_Pictographic
1F3C7         ; Extended_Pictographic
1F3C8         ; Extended_Pictographic
1F3C9         ; Extended_Pictographic
1F3CA         ; Extended_Pictographic
1F3CB..1F3CE  ; Extended_Pictographic
1F3CF..1F3D3  ; Extended_Pictographic
1F3D4..1F3DF  ; Extended_Pictographic
1F3E0..1F3E3  ; Extended_Pictographic
1F3E4         ; Extended_Pictographic
1F3E5..1F3F0  ; Extended_Pictographic
1F3F3         ; Extended_Pictographic
1F3F4         ; Extended_Pictographic
1F3F5         ; Extended_Pictographic
1F3F7         ; Extended_Pictographic
1F3F8..1F3FA  ; Extended_Pictographic
1F400..1F407  ; Extended_Pictographic
1F408         ; Extended_Pictographic
1F409..1F40B  ; Extended_Pictographic
1F40C..1F40E  ; Extended_Pictographic
1F40F..1F410  ; Extended_Pictographic
1F411..1F412  ; Extended_Pictographic
1F413         ; Extended_Pictographic
1F414         ; Extended_Pictographic
1F415         ; Extended_Pictographic
1F416         ; Extended_Pictographic
1F417..1F429  ; Extended_Pictographic
1F42A         ; Extended_Pictographic
1F42B..1F43E  ; Extended_Pictographic
1F43F         ; Extended_Pictographic
1F440         ; Extended_Pictographic
1F441         ; Extended_Pictographic
1F442..1F464  ; Extended_Pictographic
1F465         ; Extended_Pictographic
1F466..1F46B  ; Extended_Pictographic
1F46C..1F46D  ; Extended_Pictographic
1F46E..1F4AC  ; Extended_Pictographic
1F4AD         ; Extended_Pictographic
1F4AE..1F4B5  ; Extended_Pictographic
1F4B6..1F4B7  ; Extended_Pictographic
1F4B8..1F4EB  ; Extended_Pictographic
1F4EC..1F4ED  ; Extended_Pictographic
1F4EE         ; Extended_Pictographic
1F4EF         ; Extended_Pictographic
1F4F0..1F4F4  ; Extended_Pictographic
1F4F5         ; Extended_Pictographic
1F4F6..1F4F7  ; Extended_Pictographic
1F4F8         ; Extended_Pictographic
1F4F9..1F4FC  ; Extended_Pictographic
1F4FD         ; Extended_Pictographic
1F4FF..1F502  ; Extended_Pictographic
1F503         ; Extended_Pictographic
1F504..1F507  ; Extended_Pictographic
1F508         ; Extended_Pictographic
1F509         ; Extended_Pictographic
1F50A..1F514  ; Extended_Pictographic
1F515         ; Extended_Pictographic
1F516..1F52B  ; Extended_Pictographic
1F52C..1F52D  ; Extended_Pictographic
1F52E..1F53D  ; Extended_Pictographic
1F549..1F54A  ; Extended_Pictographic
1F54B..1F54E  ; Extended_Pictographic
1F550..1F55B  ; Extended_Pictographic
1F55C..1F567  ; Extended_Pictographic
1F56F..1F570  ; Extended_Pictographic
1F573..1F579  ; Extended_Pictographic
1F57A         ; Extended_Pictographic
1F587         ; Extended_Pictographic
1F58A..1F58D  ; Extended_Pictographic
1F590         ; Extended_Pictographic
1F595..1F596  ; Extended_Pictographic
1F5A4         ; Extended_Pictographic
1F5A5         ; Extended_Pictographic
1F5A8         ; Extended_Pictographic
1F5B1..1F5B2  ; Extended_Pictographic
1F5BC         ; Extended_Pictographic
1F5C2..1F5C4  ; Extended_Pictographic
1F5D1..1F5D3  ; Extended_Pictographic
1F5DC..1F5DE  ; Extended_Pictographic
1F5E1         ; Extended_Pictographic
1F5E3         ; Extended_Pictographic
1F5E8         ; Extended_Pictographic
1F5EF         ; Extended_Pictographic
1F5F3         ; Extended_Pictographic
1F5FA         ; Extended_Pictographic
1F5FB..1F5FF  ; Extended_Pictographic
1F600         ; Extended_Pictographic
1F601..1F606  ; Extended_Pictographic
1F607..1F608  ; Extended_Pictographic
1F609..1F60D  ; Extended_Pictographic
1F60E         ; Extended_Pictographic
1F60F         ; Extended_Pictographic
1F610         ; Extended_Pictographic
1F611         ; Extended_Pictographic
1F612..1F614  ; Extended_Pictographic
1F615         ; Extended_Pictographic
1F616         ; Extended_Pictographic
1F617         ; Extended_Pictographic
1F618         ; Extended_Pictographic
1F619         ; Extended_Pictographic
1F61A         ; Extended_Pictographic
1F61B         ; Extended_Pictographic
1F61C..1F61E  ; Extended_Pictographic
1F61F         ; Extended_Pictographic
1F620..1F625  ; Extended_Pictographic
1F626..1F627  ; Extended_Pictographic
1F628..1F62B  ; Extended_Pictographic
1F62C         ; Extended_Pictographic
1F62D         ; Extended_Pictographic
1F62E..1F62F  ; Extended_Pictographic
1F630..1F633  ; Extended_Pictographic
1F634         ; Extended_Pictographic
1F635         ; Extended_Pictographic
1F636         ; Extended_Pictographic
1F637..1F640  ; Extended_Pictographic
1F641..1F644  ; Extended_Pictographic
1F645..1F64F  ; Extended_Pictographic
1F680         ; Extended_Pictographic
1F681..1F682  ; Extended_Pictographic
1F683..1F685  ; Extended_Pictographic
1F686         ; Extended_Pictographic
1F687         ; Extended_Pictographic
1F688         ; Extended_Pictographic
1F689         ; Extended_Pictographic
1F68A..1F68B  ; Extended_Pictographic
1F68C         ; Extended_Pictographic
1F68D         ; Extended_Pictographic
1F68E         ; Extended_Pictographic
1F68F         ; Extended_Pictographic
1F690         ; Extended_Pictographic
1F691..1F693  ; Extended_Pictographic
1F694         ; Extended_Pictographic
1F695         ; Extended_Pictographic
1F696         ; Extended_Pictographic
1F697         ; Extended_Pictographic
1F698         ; Extended_Pictographic
1F699..1F69A  ; Extended_Pictographic
1F69B..1F6A1  ; Extended_Pictographic
1F6A2         ; Extended_Pictographic
1F6A3         ; Extended_Pictographic
1F6A4..1F6A5  ; Extended_Pictographic
1F6A6         ; Extended_Pictographic
1F6A7..1F6AD  ; Extended_Pictographic
1F6AE..1F6B1  ; Extended_Pictographic
1F6B2         ; Extended_Pictographic
1F6B3..1F6B5  ; Extended_Pictographic
1F6B6         ; Extended_Pictographic
1F6B7..1F6B8  ; Extended_Pictographic
1F6B9..1F6BE  ; Extended_Pictographic
1F6BF         ; Extended_Pictographic
1F6C0         ; Extended_Pictographic
1F6C1..1F6C5  ; Extended_Pictographic
1F6CB         ; Extended_Pictographic
1F6CC         ; Extended_Pictographic
1F6CD..1F6CF  ; Extended_Pictographic
1F6D0         ; Extended_Pictographic
1F6D1..1F6D2  ; Extended_Pictographic
1F6D5         ; Extended_Pictographic
1F6D6..1F6D7  ; Extended_Pictographic
1F6D8         ; Extended_Pictographic
1F6D9..1F6DB  ; Extended_Pictographic
1F6DC         ; Extended_Pictographic
1F6DD..1F6DF  ; Extended_Pictographic
1F6E0..1F6E5  ; Extended_Pictographic
1F6E9         ; Extended_Pictographic
1F6EB..1F6EC  ; Extended_Pictographic
1F6ED..1F6EF  ; Extended_Pictographic
1F6F0         ; Extended_Pictographic
1F6F3         ; Extended_Pictographic
1F6F4..1F6F6  ; Extended_Pictographic
1F6F7..1F6F8  ; Extended_Pictographic
1F6F9         ; Extended_Pictographic
1F6FA         ; Extended_Pictographic
1F6FB..1F6FC  ; Extended_Pictographic
1F6FD..1F6FF  ; Extended_Pictographic
1F7DA..1F7DF  ; Extended_Pictographic
1F7E0..1F7EB  ; Extended_Pictographic
1F7EC..1F7EF  ; Extended_Pictographic
1F7F0         ; Extended_Pictographic
1F7F1..1F7FF  ; Extended_Pictographic
1F80C..1F80F  ; Extended_Pictographic
1F848..1F84F  ; Extended_Pictographic
1F85A..1F85F  ; Extended_Pictographic
1F888..1F88F  ; Extended_Pictographic
1F8AE..1F8AF  ; Extended_Pictographic
1F8BC..1F8BF  ; Extended_Pictographic
1F8C2..1F8CF  ; Extended_Pictographic
1F8D9..1F8FF  ; Extended_Pictographic
1F90C         ; Extended_Pictographic
1F90D..1F90F  ; Extended_Pictographic
1F910..1F918  ; Extended_Pictographic
1F919..1F91E  ; Extended_Pictographic
1F91F         ; Extended_Pictographic
1F920..1F927  ; Extended_Pictographic
1F928..1F92F  ; Extended_Pictographic
1F930         ; Extended_Pictographic
1F931..1F932  ; Extended_Pictographic
1F933..1F93A  ; Extended_Pictographic
1F93C..1F93E  ; Extended_Pictographic
1F93F         ; Extended_Pictographic
1F940..1F945  ; Extended_Pictographic
1F947..1F94B  ; Extended_Pictographic
1F94C         ; Extended_Pictographic
1F94D..1F94F  ; Extended_Pictographic
1F950..1F95E  ; Extended_Pictographic
1F95F..1F96B  ; Extended_Pictographic
1F96C..1F970  ; Extended_Pictographic
1F971         ; Extended_Pictographic
1F972         ; Extended_Pictographic
1F973..1F976  ; Extended_Pictographic
1F977..1F978  ; Extended_Pictographic
1F979         ; Extended_Pictographic
1F97A         ; Extended_Pictographic
1F97B         ; Extended_Pictographic
1F97C..1F97F  ; Extended_Pictographic
1F980..1F984  ; Extended_Pictographic
1F985..1F991  ; Extended_Pictographic
1F992..1F997  ; Extended_Pictographic
1F998..1F9A2  ; Extended_Pictographic
1F9A3..1F9A4  ; Extended_Pictographic
1F9A5..1F9AA  ; Extended_Pictographic
1F9AB..1F9AD  ; Extended_Pictographic
1F9AE..1F9AF  ; Extended_Pictographic
1F9B0..1F9B9  ; Extended_Pictographic
1F9BA..1F9BF  ; Extended_Pictographic
1F9C0         ; Extended_Pictographic
1F9C1..1F9C2  ; Extended_Pictographic
1F9C3..1F9CA  ; Extended_Pictographic
1F9CB         ; Extended_Pictographic
1F9CC         ; Extended_Pictographic
1F9CD..1F9CF  ; Extended_Pictographic
1F9D0..1F9E6  ; Extended_Pictographic
1F9E7..1F9FF  ; Extended_Pictographic
1FA58..1FA5F  ; Extended_Pictographic
1FA6E..1FA6F  ; Extended_Pictographic
1FA70..1FA73  ; Extended_Pictographic
1FA74         ; Extended_Pictographic
1FA75..1FA77  ; Extended_Pictographic
1FA78..1FA7A  ; Extended_Pictographic
1FA7B..1FA7C  ; Extended_Pictographic
1FA7D..1FA7F  ; Extended_Pictographic
1FA80..1FA82  ; Extended_Pictographic
1FA83..1FA86  ; Extended_Pictographic
1FA87..1FA88  ; Extended_Pictographic
1FA89         ; Extended_Pictographic
1FA8A         ; Extended_Pictographic
1FA8B..1FA8D  ; Extended_Pictographic
1FA8E         ; Extended_Pictographic
1FA8F         ; Extended_Pictographic
1FA90..1FA95  ; Extended_Pictographic
1FA96..1FAA8  ; Extended_Pictographic
1FAA9..1FAAC  ; Extended_Pictographic
1FAAD..1FAAF  ; Extended_Pictographic
1FAB0..1FAB6  ; Extended_Pictographic
1FAB7..1FABA  ; Extended_Pictographic
1FABB..1FABD  ; Extended_Pictographic
1FABE         ; Extended_Pictographic
1FABF         ; Extended_Pictographic
1FAC0..1FAC2  ; Extended_Pictographic
1FAC3..1FAC5  ; Extended_Pictographic
1FAC6         ; Extended_Pictographic
1FAC7         ; Extended_Pictographic
1FAC8         ; Extended_Pictographic
1FAC9..1FACC  ; Extended_Pictographic
1FACD         ; Extended_Pictographic
1FACE..1FACF  ; Extended_Pictographic
1FAD0..1FAD6  ; Extended_Pictographic
1FAD7..1FAD9  ; Extended_Pictographic
1FADA..1FADB  ; Extended_Pictographic
1FADC         ; Extended_Pictographic
1FADD..1FADE  ; Extended_Pictographic
1FADF         ; Extended_Pictographic
1FAE0..1FAE7  ; Extended_Pictographic
1FAE8         ; Extended_Pictographic
1FAE9         ; Extended_Pictographic
1FAEA         ; Extended_Pictographic
1FAEB..1FAEE  ; Extended_Pictographic
1FAEF         ; Extended_Pictographic
1FAF0..1FAF6  ; Extended_Pictographic
1FAF7..1FAF8  ; Extended_Pictographic
1FAF9..1FAFF  ; Extended_Pictographic
1FC00..1FFFD  ; Extended_Pictographic
)UCD";

// DerivedCoreProperties.txt
static const char unicode17IndicConjunctBreak[] = R"UCD(
094D          ; InCB; Linker
09CD          ; InCB; Linker
0ACD          ; InCB; Linker
0B4D          ; InCB; Linker
0C4D          ; InCB; Linker
0D4D          ; InCB; Linker
1039          ; InCB; Linker
17D2          ; InCB; Linker
1A60          ; InCB; Linker
1B44          ; InCB; Linker
1BAB          ; InCB; Linker
A9C0          ; InCB; Linker
AAF6          ; InCB; Linker
10A3F         ; InCB; Linker
11133         ; InCB; Linker
113D0         ; InCB; Linker
1193E         ; InCB; Linker
11A47         ; InCB; Linker
11A99         ; InCB; Linker
11F42         ; InCB; Linker
0915..0939    ; InCB; Consonant
0958..095F    ; InCB; Consonant
0978..097F    ; InCB; Consonant
0995..09A8    ; InCB; Consonant
09AA..09B0    ; InCB; Consonant
09B2          ; InCB; Consonant
09B6..09B9    ; InCB; Consonant
09DC..09DD    ; InCB; Consonant
09DF          ; InCB; Consonant
09F0..09F1    ; InCB; Consonant
0A95..0AA8    ; InCB; Consonant
0AAA..0AB0    ; InCB; Consonant
0AB2..0AB3    ; InCB; Consonant
0AB5..0AB9    ; InCB; Consonant
0AF9          ; InCB; Consonant
0B15..0B28    ; InCB; Consonant
0B2A..0B30    ; InCB; Consonant
0B32..0B33    ; InCB; Consonant
0B35..0B39    ; InCB; Consonant
0B5C..0B5D    ; InCB; Consonant
0B5F          ; InCB; Consonant
0B71          ; InCB; Consonant
0C15..0C28    ; InCB; Consonant
0C2A..0C39    ; InCB; Consonant
0C58..0C5A    ; InCB; Consonant
0D15..0D3A    ; InCB; Consonant
1000..102A    ; InCB; Consonant
103F          ; InCB; Consonant
1050..1055    ; InCB; Consonant
105A..105D    ; InCB; Consonant
1061          ; InCB; Consonant
1065..1066    ; InCB; Consonant
106E..1070    ; InCB; Consonant
1075..1081    ; InCB; Consonant
108E          ; InCB; Consonant
1780..17B3    ; InCB; Consonant
1A20..1A54    ; InCB; Consonant
1B0B..1B0C    ; InCB; Consonant
1B13..1B33    ; InCB; Consonant
1B45..1B4C    ; InCB; Consonant
1B83..1BA0    ; InCB; Consonant
1BAE..1BAF    ; InCB; Consonant
1BBB..1BBD    ; InCB; Consonant
A989..A98B    ; InCB; Consonant
A98F..A9B2    ; InCB; Consonant
A9E0..A9E4    ; InCB; Consonant
A9E7..A9EF    ; InCB; Consonant
A9FA..A9FE    ; InCB; Consonant
AA60..AA6F    ; InCB; Consonant
AA71..AA73    ; InCB; Consonant
AA7A          ; InCB; Consonant
AA7E..AA7F    ; InCB; Consonant
AAE0..AAEA    ; InCB; Consonant
ABC0..ABDA    ; InCB; Consonant
10A00         ; InCB; Consonant
10A10..10A13  ; InCB; Consonant
10A15..10A17  ; InCB; Consonant
10A19..10A35  ; InCB; Consonant
11103..11126  ; InCB; Consonant
11144         ; InCB; Consonant
11147         ; InCB; Consonant
11380..11389  ; InCB; Consonant
1138B         ; InCB; Consonant
1138E         ; InCB; Consonant
11390..113B5  ; InCB; Consonant
11900..11906  ; InCB; Consonant
11909         ; InCB; Consonant
1190C..11913  ; InCB; Consonant
11915..11916  ; InCB; Consonant
11918..1192F  ; InCB; Consonant
11A00         ; InCB; Consonant
11A0B..11A32  ; InCB; Consonant
11A50         ; InCB; Consonant
11A5C..11A83  ; InCB; Consonant
11F04..11F10  ; InCB; Consonant
11F12..11F33  ; InCB; Consonant
0300..036F    ; InCB; Extend
0483..0487    ; InCB; Extend
0488..0489    ; InCB; Extend
0591..05BD    ; InCB; Extend
05BF          ; InCB; Extend
05C1..05C2    ; InCB; Extend
05C4..05C5    ; InCB; Extend
05C7          ; InCB; Extend
0610..061A    ; InCB; Extend
064B..065F    ; InCB; Extend
0670          ; InCB; Extend
06D6..06DC    ; InCB; Extend
06DF..06E4    ; InCB; Extend
06E7..06E8    ; InCB; Extend
06EA..06ED    ; InCB; Extend
0711          ; InCB; Extend
0730..074A    ; InCB; Extend
07A6..07B0    ; InCB; Extend
07EB..07F3    ; InCB; Extend
07FD          ; InCB; Extend
0816..0819    ; InCB; Extend
081B..0823    ; InCB; Extend
0825..0827    ; InCB; Extend
0829..082D    ; InCB; Extend
0859..085B    ; InCB; Extend
0897..089F    ; InCB; Extend
08CA..08E1    ; InCB; Extend
08E3..0902    ; InCB; Extend
093A          ; InCB; Extend
093C          ; InCB; Extend
0941..0948    ; InCB; Extend
0951..0957    ; InCB; Extend
0962..0963    ; InCB; Extend
0981          ; InCB; Extend
09BC          ; InCB; Extend
09BE          ; InCB; Extend
09C1..09C4    ; InCB; Extend
09D7          ; InCB; Extend
09E2..09E3    ; InCB; Extend
09FE          ; InCB; Extend
0A01..0A02    ; InCB; Extend
0A3C          ; InCB; Extend
0A41..0A42    ; InCB; Extend
0A47..0A48    ; InCB; Extend
0A4B..0A4D    ; InCB; Extend
0A51          ; InCB; Extend
0A70..0A71    ; InCB; Extend
0A75          ; InCB; Extend
0A81..0A82    ; InCB; Extend
0ABC          ; InCB; Extend
0AC1..0AC5    ; InCB; Extend
0AC7..0AC8    ; InCB; Extend
0AE2..0AE3    ; InCB; Extend
0AFA..0AFF    ; InCB; Extend
0B01          ; InCB; Extend
0B3C          ; InCB; Extend
0B3E          ; InCB; Extend
0B3F          ; InCB; Extend
0B41..0B44    ; InCB; Extend
0B55..0B56    ; InCB; Extend
0B57          ; InCB; Extend
0B62..0B63    ; InCB; Extend
0B82          ; InCB; Extend
0BBE          ; InCB; Extend
0BC0          ; InCB; Extend
0BCD          ; InCB; Extend
0BD7          ; InCB; Extend
0C00          ; InCB; Extend
0C04          ; InCB; Extend
0C3C          ; InCB; Extend
0C3E..0C40    ; InCB; Extend
0C46..0C48    ; InCB; Extend
0C4A..0C4C    ; InCB; Extend
0C55..0C56    ; InCB; Extend
0C62..0C63    ; InCB; Extend
0C81          ; InCB; Extend
0CBC          ; InCB; Extend
0CBF          ; InCB; Extend
0CC0          ; InCB; Extend
0CC2          ; InCB; Extend
0CC6          ; InCB; Extend
0CC7..0CC8    ; InCB; Extend
0CCA..0CCB    ; InCB; Extend
0CCC..0CCD    ; InCB; Extend
0CD5..0CD6    ; InCB; Extend
0CE2..0CE3    ; InCB; Extend
0D00..0D01    ; InCB; Extend
0D3B..0D3C    ; InCB; Extend
0D3E          ; InCB; Extend
0D41..0D44    ; InCB; Extend
0D57          ; InCB; Extend
0D62..0D63    ; InCB; Extend
0D81          ; InCB; Extend
0DCA          ; InCB; Extend
0DCF          ; InCB; Extend
0DD2..0DD4    ; InCB; Extend
0DD6          ; InCB; Extend
0DDF          ; InCB; Extend
0E31          ; InCB; Extend
0E34..0E3A    ; InCB; Extend
0E47..0E4E    ; InCB; Extend
0EB1          ; InCB; Extend
0EB4..0EBC    ; InCB; Extend
0EC8..0ECE    ; InCB; Extend
0F18..0F19    ; InCB; Extend
0F35          ; InCB; Extend
0F37          ; InCB; Extend
0F39          ; InCB; Extend
0F71..0F7E    ; InCB; Extend
0F80..0F84    ; InCB; Extend
0F86..0F87    ; InCB; Extend
0F8D..0F97    ; InCB; Extend
0F99..0FBC    ; InCB; Extend
0FC6          ; InCB; Extend
102D..1030    ; InCB; Extend
1032..1037    ; InCB; Extend
103A          ; InCB; Extend
103D..103E    ; InCB; Extend
1058..1059    ; InCB; Extend
105E..1060    ; InCB; Extend
1071..1074    ; InCB; Extend
1082          ; InCB; Extend
1085..1086    ; InCB; Extend
108D          ; InCB; Extend
109D          ; InCB; Extend
135D..135F    ; InCB; Extend
1712..1714    ; InCB; Extend
1715          ; InCB; Extend
1732..1733    ; InCB; Extend
1734          ; InCB; Extend
1752..1753    ; InCB; Extend
1772..1773    ; InCB; Extend
17B4..17B5    ; InCB; Extend
17B7..17BD    ; InCB; Extend
17C6          ; InCB; Extend
17C9..17D1    ; InCB; Extend
17D3          ; InCB; Extend
17DD          ; InCB; Extend
180B..180D    ; InCB; Extend
180F          ; InCB; Extend
1885..1886    ; InCB; Extend
18A9          ; InCB; Extend
1920..1922    ; InCB; Extend
1927..1928    ; InCB; Extend
1932          ; InCB; Extend
1939..193B    ; InCB; Extend
1A17..1A18    ; InCB; Extend
1A1B          ; InCB; Extend
1A56          ; InCB; Extend
1A58..1A5E    ; InCB; Extend
1A62          ; InCB; Extend
1A65..1A6C    ; InCB; Extend
1A73..1A7C    ; InCB; Extend
1A7F          ; InCB; Extend
1AB0..1ABD    ; InCB; Extend
1ABE          ; InCB; Extend
1ABF..1ADD    ; InCB; Extend
1AE0..1AEB    ; InCB; Extend
1B00..1B03    ; InCB; Extend
1B34          ; InCB; Extend
1B35          ; InCB; Extend
1B36..1B3A    ; InCB; Extend
1B3B          ; InCB; Extend
1B3C          ; InCB; Extend
1B3D          ; InCB; Extend
1B42          ; InCB; Extend
1B43          ; InCB; Extend
1B6B..1B73    ; InCB; Extend
1B80..1B81    ; InCB; Extend
1BA2..1BA5    ; InCB; Extend
1BA8..1BA9    ; InCB; Extend
1BAA          ; InCB; Extend
1BAC..1BAD    ; InCB; Extend
1BE6          ; InCB; Extend
1BE8..1BE9    ; InCB; Extend
1BED          ; InCB; Extend
1BEF..1BF1    ; InCB; Extend
1BF2..1BF3    ; InCB; Extend
1C2C..1C33    ; InCB; Extend
1C36..1C37    ; InCB; Extend
1CD0..1CD2    ; InCB; Extend
1CD4..1CE0    ; InCB; Extend
1CE2..1CE8    ; InCB; Extend
1CED          ; InCB; Extend
1CF4          ; InCB; Extend
1CF8..1CF9    ; InCB; Extend
1DC0..1DFF    ; InCB; Extend
200D          ; InCB; Extend
20D0..20DC    ; InCB; Extend
20DD..20E0    ; InCB; Extend
20E1          ; InCB; Extend
20E2..20E4    ; InCB; Extend
20E5..20F0    ; InCB; Extend
2CEF..2CF1    ; InCB; Extend
2D7F          ; InCB; Extend
2DE0..2DFF    ; InCB; Extend
302A..302D    ; InCB; Extend
302E..302F    ; InCB; Extend
3099..309A    ; InCB; Extend
A66F          ; InCB; Extend
A670..A672    ; InCB; Extend
A674..A67D    ; InCB; Extend
A69E..A69F    ; InCB; Extend
A6F0..A6F1    ; InCB; Extend
A802          ; InCB; Extend
A806          ; InCB; Extend
A80B          ; InCB; Extend
A825..A826    ; InCB; Extend
A82C          ; InCB; Extend
A8C4..A8C5    ; InCB; Extend
A8E0..A8F1    ; InCB; Extend
A8FF          ; InCB; Extend
A926..A92D    ; InCB; Extend
A947..A951    ; InCB; Extend
A953          ; InCB; Extend
A980..A982    ; InCB; Extend
A9B3          ; InCB; Extend
A9B6..A9B9    ; InCB; Extend
A9BC..A9BD    ; InCB; Extend
A9E5          ; InCB; Extend
AA29..AA2E    ; InCB; Extend
AA31..AA32    ; InCB; Extend
AA35..AA36    ; InCB; Extend
AA43          ; InCB; Extend
AA4C          ; InCB; Extend
AA7C          ; InCB; Extend
AAB0          ; InCB; Extend
AAB2..AAB4    ; InCB; Extend
AAB7..AAB8    ; InCB; Extend
AABE..AABF    ; InCB; Extend
AAC1          ; InCB; Extend
AAEC..AAED    ; InCB; Extend
ABE5          ; InCB; Extend
ABE8          ; InCB; Extend
ABED          ; InCB; Extend
FB1E          ; InCB; Extend
FE00..FE0F    ; InCB; Extend
FE20..FE2F    ; InCB; Extend
FF9E..FF9F    ; InCB; Extend
101FD         ; InCB; Extend
102E0         ; InCB; Extend
10376..1037A  ; InCB; Extend
10A01..10A03  ; InCB; Extend
10A05..10A06  ; InCB; Extend
10A0C..10A0F  ; InCB; Extend
10A38..10A3A  ; InCB; Extend
10AE5..10AE6  ; InCB; Extend
10D24..10D27  ; InCB; Extend
10D69..10D6D  ; InCB; Extend
10EAB..10EAC  ; InCB; Extend
10EFA..10EFF  ; InCB; Extend
10F46..10F50  ; InCB; Extend
10F82..10F85  ; InCB; Extend
11001         ; InCB; Extend
11038..11046  ; InCB; Extend
11070         ; InCB; Extend
11073..11074  ; InCB; Extend
1107F..11081  ; InCB; Extend
110B3..110B6  ; InCB; Extend
110B9..110BA  ; InCB; Extend
110C2         ; InCB; Extend
11100..11102  ; InCB; Extend
11127..1112B  ; InCB; Extend
1112D..11132  ; InCB; Extend
11134         ; InCB; Extend
11173         ; InCB; Extend
11180..11181  ; InCB; Extend
111B6..111BE  ; InCB; Extend
111C0         ; InCB; Extend
111C9..111CC  ; InCB; Extend
111CF         ; InCB; Extend
1122F..11231  ; InCB; Extend
11234         ; InCB; Extend
11235         ; InCB; Extend
11236..11237  ; InCB; Extend
1123E         ; InCB; Extend
11241         ; InCB; Extend
112DF         ; InCB; Extend
112E3..112EA  ; InCB; Extend
11300..11301  ; InCB; Extend
1133B..1133C  ; InCB; Extend
1133E         ; InCB; Extend
11340         ; InCB; Extend
1134D         ; InCB; Extend
11357         ; InCB; Extend
11366..1136C  ; InCB; Extend
11370..11374  ; InCB; Extend
113B8         ; InCB; Extend
113BB..113C0  ; InCB; Extend
113C2         ; InCB; Extend
113C5         ; InCB; Extend
113C7..113C9  ; InCB; Extend
113CE         ; InCB; Extend
113CF         ; InCB; Extend
113D2         ; InCB; Extend
113E1..113E2  ; InCB; Extend
11438..1143F  ; InCB; Extend
11442..11444  ; InCB; Extend
11446         ; InCB; Extend
1145E         ; InCB; Extend
114B0         ; InCB; Extend
114B3..114B8  ; InCB; Extend
114BA         ; InCB; Extend
114BD         ; InCB; Extend
114BF..114C0  ; InCB; Extend
114C2..114C3  ; InCB; Extend
115AF         ; InCB; Extend
115B2..115B5  ; InCB; Extend
115BC..115BD  ; InCB; Extend
115BF..115C0  ; InCB; Extend
115DC..115DD  ; InCB; Extend
11633..1163A  ; InCB; Extend
1163D         ; InCB; Extend
1163F..11640  ; InCB; Extend
116AB         ; InCB; Extend
116AD         ; InCB; Extend
116B0..116B5  ; InCB; Extend
116B6         ; InCB; Extend
116B7         ; InCB; Extend
1171D         ; InCB; Extend
1171F         ; InCB; Extend
11722..11725  ; InCB; Extend
11727..1172B  ; InCB; Extend
1182F..11837  ; InCB; Extend
11839..1183A  ; InCB; Extend
11930         ; InCB; Extend
1193B..1193C  ; InCB; Extend
1193D         ; InCB; Extend
11943         ; InCB; Extend
119D4..119D7  ; InCB; Extend
119DA..119DB  ; InCB; Extend
119E0         ; InCB; Extend
11A01..11A0A  ; InCB; Extend
11A33..11A38  ; InCB; Extend
11A3B..11A3E  ; InCB; Extend
11A51..11A56  ; InCB; Extend
11A59..11A5B  ; InCB; Extend
11A8A..11A96  ; InCB; Extend
11A98         ; InCB; Extend
11B60         ; InCB; Extend
11B62..11B64  ; InCB; Extend
11B66         ; InCB; Extend
11C30..11C36  ; InCB; Extend
11C38..11C3D  ; InCB; Extend
11C3F         ; InCB; Extend
11C92..11CA7  ; InCB; Extend
11CAA..11CB0  ; InCB; Extend
11CB2..11CB3  ; InCB; Extend
11CB5..11CB6  ; InCB; Extend
11D31..11D36  ; InCB; Extend
11D3A         ; InCB; Extend
11D3C..11D3D  ; InCB; Extend
11D3F..11D45  ; InCB; Extend
11D47         ; InCB; Extend
11D90..11D91  ; InCB; Extend
11D95         ; InCB; Extend
11D97         ; InCB; Extend
11EF3..11EF4  ; InCB; Extend
11F00..11F01  ; InCB; Extend
11F36..11F3A  ; InCB; Extend
11F40         ; InCB; Extend
11F41         ; InCB; Extend
11F5A         ; InCB; Extend
13440         ; InCB; Extend
13447..13455  ; InCB; Extend
1611E..16129  ; InCB; Extend
1612D..1612F  ; InCB; Extend
16AF0..16AF4  ; InCB; Extend
16B30..16B36  ; InCB; Extend
16F4F         ; InCB; Extend
16F8F..16F92  ; InCB; Extend
16FE4         ; InCB; Extend
16FF0..16FF1  ; InCB; Extend
1BC9D..1BC9E  ; InCB; Extend
1CF00..1CF2D  ; InCB; Extend
1CF30..1CF46  ; InCB; Extend
1D165..1D166  ; InCB; Extend
1D167..1D169  ; InCB; Extend
1D16D..1D172  ; InCB; Extend
1D17B..1D182  ; InCB; Extend
1D185..1D18B  ; InCB; Extend
1D1AA..1D1AD  ; InCB; Extend
1D242..1D244  ; InCB; Extend
1DA00..1DA36  ; InCB; Extend
1DA3B..1DA6C  ; InCB; Extend
1DA75         ; InCB; Extend
1DA84         ; InCB; Extend
1DA9B..1DA9F  ; InCB; Extend
1DAA1..1DAAF  ; InCB; Extend
1E000..1E006  ; InCB; Extend
1E008..1E018  ; InCB; Extend
1E01B..1E021  ; InCB; Extend
1E023..1E024  ; InCB; Extend
1E026..1E02A  ; InCB; Extend
1E08F         ; InCB; Extend
1E130..1E136  ; InCB; Extend
1E2AE         ; InCB; Extend
1E2EC..1E2EF  ; InCB; Extend
1E4EC..1E4EF  ; InCB; Extend
1E5EE..1E5EF  ; InCB; Extend
1E6E3         ; InCB; Extend
1E6E6         ; InCB; Extend
1E6EE..1E6EF  ; InCB; Extend
1E6F5         ; InCB; Extend
1E8D0..1E8D6  ; InCB; Extend
1E944..1E94A  ; InCB; Extend
1F3FB..1F3FF  ; InCB; Extend
E0020..E007F  ; InCB; Extend
E0100..E01EF  ; InCB; Extend
)UCD";
