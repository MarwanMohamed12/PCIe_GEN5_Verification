vlib work
vlog RTL/*.v +cover -covercells +define+SIM
vlog TB/PIPE_if.sv TB/LPIF_if.sv TB/PCIe_Top.sv TB/PCIe_pkg.sv +define+SIM
vsim -voptargs=+acc work.PCIe_Top -classdebug -uvmcontrol=all -cover

add wave -position insertpoint sim:/PCIe_Top/LPIF_if_U_h/*
add wave -position insertpoint sim:/PCIe_Top/LPIF_if_U_h/*
add wave -position insertpoint sim:/PCIe_Top/LPIF_if_U_h/*
add wave -position insertpoint sim:/PCIe_Top/LPIF_if_U_h/*


run -all

coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 156 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 174 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 175 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 178 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 180 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 182 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 184 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 188 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 190 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 281 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 284 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 285 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 286 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 288 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 293 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 298 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 299 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 301 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 303 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 308 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 312 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 317 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 319 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 324 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 329 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 330 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 332 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 334 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 365 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 368 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 369 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 372 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 373 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 374 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 375 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 377 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 382 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 387 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 388 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 391 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 392 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 395 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 402 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 403 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 412 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 477 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 480 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 481 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 485 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 486 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 487 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 488 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 490 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 495 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 497 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 504 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 509 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 510 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 513 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 514 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 517 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 519 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 526 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 527 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 563 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 566 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 567 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 569 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 573 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 574 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 579 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 580 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 582 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 584 -code s

coverage exclude -src RTL/Gen_ctrl.v -line 56 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 655 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 659 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 660 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 663 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 668 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 674 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 675 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 677 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 679 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 685 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 689 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 690 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 691 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 692 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 695 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 701 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 707 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 708 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 709 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 710 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 712 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 714 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 751 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 752 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 756 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 757 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 763 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 764 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 765 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 768 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 774 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 780 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 781 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 787 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 788 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 791 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/OS_Checker.v -line 793 -code s
coverage exclude -src E:/study/Grad_BY_Youssef/RTL/Counter.v -line 7 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1106 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1108 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1110 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1115 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1117 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1119 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1124 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1126 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1128 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1143 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1145 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1147 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1152 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1154 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1156 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1161 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1163 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1165 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1171 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1179 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1181 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1183 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1187 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1189 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1191 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1195 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1197 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1199 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1203 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1205 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1207 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1216 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1219 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1222 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1250 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1252 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1254 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1259 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1261 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1263 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1268 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1270 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1272 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1281 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1287 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1289 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1291 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1296 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1298 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1300 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1305 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1307 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1309 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1315 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1323 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1325 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1327 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1331 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1333 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1335 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1339 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1341 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1343 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1347 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1349 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1351 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1358 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1361 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1364 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1389 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1390 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1391 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1392 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 1393 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2018 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2021 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2024 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2027 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2032 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2035 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2038 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2047 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2050 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2053 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2062 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2065 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2068 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2089 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2092 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2095 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2098 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2103 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2106 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2109 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2135 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2138 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2139 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2140 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2141 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2143 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2162 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2165 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2166 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2167 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2168 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2170 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2189 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2191 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2192 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2193 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2194 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2196 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2200 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2202 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2203 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2204 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2205 -code s
coverage exclude -src RTL/OS_GENERATOR.v -line 2207 -code s
coverage exclude -src RTL/Scrambler.v -line 43 -code s
coverage exclude -src RTL/Scrambler.v -line 45 -code s
coverage exclude -src RTL/Scrambler.v -line 51 -code s
coverage exclude -src RTL/Scrambler.v -line 53 -code s


coverage save PCIE_results.ucdb -onexit 


quit -sim


vcover report PCIE_results.ucdb -cvg -details -output functional_coverage.txt      ;# covergroups
vcover report PCIE_results.ucdb -code s -details -output statement_coverage.txt    ;# statements
vcover report PCIE_results.ucdb -code c -details -output condition_coverage.txt    ;# conditionals
vcover report PCIE_results.ucdb -code t -details -output toggle_coverage.txt       ;# toggles

