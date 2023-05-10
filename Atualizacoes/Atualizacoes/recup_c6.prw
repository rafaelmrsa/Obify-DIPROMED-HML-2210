#INCLUDE "rwmake.ch"
// atualiza:
// C6_QTDENT

User Function RECUP_c6()  
U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009
Processa({|| RECUPQTDENT() })

MsgBox("Fim da atualizacao no SC6 - C6_QTDVEN","Atencao","INFO")

Return                      

////////////////////////////
Static Function RECUPQTDENT()

dBSelectArea("SC6")
dbSetOrder(1)

ProcRegua(Reccount())

dbGotop()

While !Eof()                   

   IncProc( "Lendo o SC6 - Pedido " + SC6->C6_NUM )
   
   dBSelectArea("SC9")
   dbSetOrder(1)
   
   If dbSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM)
	   dBSelectArea("SC6")
	   RecLock("SC6",.F.)
	   Replace SC6->C6_QTDVEN WITH SC9->C9_QTDVEN
	   MsUnlock()
   EndIf

   dBSelectArea("SC6")
   dBSkip()                                   
   
Enddo                                    

Return
