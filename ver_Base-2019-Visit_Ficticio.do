version 14.0
cap log close
cap mkdir Logs
log using Logs/ver_Base-2019-Visit_Ficticio.log, replace
set linesize 255
set more off
clear

use "Bases/2019-Visit_Ficticio"

isid AP

assert AP =="Total AP" in L
assert inlist(Categ,"PN","RNac","RNat","MN","RNEd") in 1/`=_N-1'

assert Catego =="MN" if AP=="Laguna de los Pozuelos"
gen byte aux = 1 if strpos(AP, "-") & Port=="Subtotal"

assert aux ==1 if Port =="Subtotal"
drop aux

assert inlist(Reg,"PATAGONIA","NEA","NOA","CENTRO") in 1/`=_N-1'
assert Reg=="Total AP" in L

assert Port =="Total"  | Port =="Subtotal" | (Port =="Total AP" in L)

assert Clasif_Port =="UNIPORT"  | Clasif_Port =="MULTIPORT" |                ///
(Clasif_Port =="Total AP" in L)

assert Acceso =="COBRA"  | Acceso =="NO COBRA" | (Acceso=="Total AP" in L)
assert AP_Separador == AP if Port=="Total"
assert AP_Separador == AP_Separador[_n-1] if Port=="Subtotal"
assert AP_Separador == "Total AP" in L

*Comprueba que no haya meses missing
forval i = 1/12 {
    foreach j in ext nacmay rprov rloc est jp men total nactotal {
	assert m`i'_2019`j'!=. 
	}
}
	
*Comprueba trimestres, semestres y total anual
foreach i in ext nacmay rprov rloc est jp men total nactotal {
    assert trim1_2019`i' == m1_2019`i' + m2_2019`i' + m3_2019`i'  
    assert trim2_2019`i' == m4_2019`i' + m5_2019`i' + m6_2019`i' 
    assert trim3_2019`i' == m7_2019`i' + m8_2019`i' + m9_2019`i'
    assert trim4_2019`i' == m10_2019`i' + m11_2019`i' + m12_2019`i'
    assert sem1_2019`i' == trim1_2019`i' + trim2_2019`i' 
    assert sem2_2019`i' == trim3_2019`i' + trim4_2019`i'
    assert total_2019`i' == sem1_2019`i' + sem2_2019`i'
}

local foo = 1 
*Confirma acumulados
forval i = 2/12 {
    foreach k in ext nacmay rprov rloc est jp men total nactotal {
        assert ac`i'_2019`k' >= ac`foo'_2019`k'
	 assert ac12_2019`k' == total_2019`k'
        }
 local foo = `foo' + 1
}

*Confirma trimestres y semestres contra acumulados
foreach i in ext nacmay rprov rloc est jp men total nactotal {
    assert trim1_2019`i'== ac3_2019`i'
    assert trim2_2019`i'== ac6_2019`i'-trim1_2019`i'
    assert trim3_2019`i'== ac9_2019`i'-trim1_2019`i'-trim2_2019`i'
    assert trim4_2019`i'== ac12_2019`i'-trim1_2019`i'-trim2_2019`i'-trim3_2019`i'
    assert sem1_2019`i'== ac6_2019`i'
    assert sem2_2019`i'== ac12_2019`i'-sem1_2019`i'
}

*Confirma total nacionales y con cobro y sin cobro
assert total_2019nactotal == total_2019total - total_2019ext
assert total_2019nactotal== ac12_2019nactotal

log close
exit
