/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ DIPA053()บAutor ณMAXIMO CANUTO       บ Data ณ  11/11//2010 บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc. Efetua transfer๊ncia automแtica entre cd's                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Estoques Dipromed.                              บฑฑ
ฑฑ------------------------------------------------------------------------บฑฑ
ฑฑบHist๓rico ณ 				                                              บฑฑ
ฑฑบ16/02/11  ณ Tratamento gravando o Status para inibir transf. simultโneaบฑฑ
ฑฑบ18/02/11  ณ Alterado tratamento p/ inibir transf. simultโnea usando    บฑฑ
ฑฑ			 ณ lockByName e UnLockByName 								  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿           
*/
                                 
#INCLUDE "RWMAKE.CH"

                       
User Function DIPA53ESC()                             

If cEmpAnt <> '01'
	
	MsgBox("Op็ใo desabilita para esta empresa ","Aten็ใo","OK")

ElseIf cEmpAnt == "01"

	If cFilAnt == '01'
		If MsgBox("CONFIRMA DIPROMED CD COMO DESTINO? ","Aten็ใo","YESNO")
			U_DIPA053C()     
		Else
			Return()
		Endif
	ElseIf cFilAnt == '04'
		If MsgBox("CONFIRMA DIPROMED MTZ COMO DESTINO? ","Aten็ใo","YESNO")
			U_DIPA053C()     
		Else
			Return()
		Endif		
	Endif
	      	                                          
Endif

Return()