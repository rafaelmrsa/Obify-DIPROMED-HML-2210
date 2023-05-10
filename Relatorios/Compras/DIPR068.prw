/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณDipr068() ณ Autor ณJailton B Santos-JBS   ณ Data ณ17/07/2010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Relatorio de agendamentos existens dentro de um periodo    ณฑฑ
ฑฑณ          ณ informado.                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Especifico De Compras Dipromed                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ  Motivo da Alteracao                            ณฑฑ                  
ฑฑณMaximo ณ    13/09/10  ณ Ajuste trocando a tabela de pedido de compra para a tabela SZO                                                  ณฑฑ                  
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ            ณ        ณ                                                 ณฑฑ
ฑฑณ            ณ        ณ                                                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#DEFINE say_tit 1
#DEFINE say_det 2
#DEFINE say_rep 3               

User Function Dipr068()

Local lQry1
Local aArea  := GetArea()

Private QRY1
Private nLastKey := 0
Private nTotVol  := 0
Private nTotVoG  := 0 
Private dDataRel := cTod('')
Private aDados   := {}
Private aRCampos := {}
Private aQuery   := {}
Private lEnd     := .f.
Private cPerg    := Padr("DIPR068",10)
Private aReturn  := {"Zebrado", 1,"Administracao", 1, 2, 1,"",1}
//---------------------------------------------------------------------------------------
// Configura os dados do relatorio
//---------------------------------------------------------------------------------------
aAdd(aDados,"TRB_AG") 
aAdd(aDados,OemTOAnsi("Agenda de recebimento de pedidos de compra",72))    // 02
aAdd(aDados,OemToAnsi("",72))// 03
aAdd(aDados,OemToAnsi("",72))       // 04
aAdd(aDados,"G")              // 05
aAdd(aDados,200)              // 06
aAdd(aDados,"")               // 07
aAdd(aDados,"")               // 08
aAdd(aDados,OemTOAnsi("Agenda de recebimento de pedidos de compra",72))
aAdd(aDados,aReturn)          // 10
aAdd(aDados,"DIPR068")        // 11
//aAdd(aDados,{{||.t.},{|| .t.}})// 12
aAdd(aDados,{{||fQuebra()},{|| fFinal()}})// 12

aAdd(aDados,Nil)              // 13
//---------------------------------------------------------------------------------------
// Cria o grupo de perguntas
//---------------------------------------------------------------------------------------
fAjustSX1()
If !Pergunte(cPerg, .T.)
    Return(.F.)
EndIf
//---------------------------------------------------------------------------------------
aDados[07] := "Data de " + Dtoc(MV_PAR01)+"  ate " + Dtoc(MV_PAR02)
//---------------------------------------------------------------------------------------
// Campos do relatorio
//---------------------------------------------------------------------------------------                          
aAdd(aRCampos,{"ZO_CODIGO" ,"",AvSx3("ZO_CODIGO",5),AvSx3("ZO_CODIGO",6)})
aAdd(aRCampos,{"ZO_DTENTRE" ,"",AvSx3("ZO_DTENTRE",5),AvSx3("ZO_DTENTRE",6)})
aAdd(aRCampos,{"ZO_HRENTRE" ,"",AvSx3("ZO_HRENTRE",5),AvSx3("ZO_HRENTRE",6)})
aAdd(aRCampos,{"ZO_FORNECE" ,"",AvSx3("ZO_FORNECE",5),AvSx3("ZO_FORNECE",6)})
aAdd(aRCampos,{"ZO_LOJA" ,"",AvSx3("ZO_LOJA",5),AvSx3("ZO_LOJA",6)})
aAdd(aRCampos,{"A2_NREDUZ" ,"",AvSx3("A2_NREDUZ",5),AvSx3("A2_NREDUZ",6)})
aAdd(aRCampos,{"ZO_TRANSP" ,"",AvSx3("ZO_TRANSP",5),AvSx3("ZO_TRANSP",6)})
aAdd(aRCampos,{"A4_NREDUZ" ,"",AvSx3("A4_NREDUZ",5),AvSx3("A4_NREDUZ",6)})
aAdd(aRCampos,{"ZO_CONTATO" ,"",AvSx3("ZO_CONTATO",5),AvSx3("ZO_CONTATO",6)})
aAdd(aRCampos,{"ZO_FONECON" ,"",AvSx3("ZO_FONECON",5),AvSx3("ZO_FONECON",6)})
aAdd(aRCampos,{"ZO_PCOMPRA" ,"",AvSx3("ZO_PCOMPRA",5),AvSx3("ZO_PCOMPRA",6)})
aAdd(aRCampos,{{|| Transform(TRB_AG->ZO_VOLUME,"@e 999,999,999")} ,"",AvSx3("ZO_VOLUME",5),""})

aRCampos := E_CriaRCampos(aRCampos,"E")

Processa({|| lQry1 := fQuery()},"Filtrando Agendamentos...",,.t.)

Begin Sequence

    If !lQry1
	    MsgInfo("Nใo encontrado dados que satisfa็am aos parametros informados pelo usuario! ","Aten็ใo")
	    Break
     EndIf            

     aReturn	:= {"Zebrado", 1,"Administracao", 1, 2, 1,"",1}
     aDados[10] :=aReturn 
     //---------------------------------------------------------------------------------------
     // Mostra o relatorio
     //---------------------------------------------------------------------------------------
     TRB_AG->(dbGotop())
     TRB_AG->(E_Report(aDados,aRCampos))

End Sequence     

TRB_AG->(dbCloseArea())

Return(.t.)  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQuery()  บAutor  ณJailton B Santos-JBSบ Data ณ 17/07/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca todas as agendas existentes dentro do periodo infor- บฑฑ
ฑฑบ          ณ mado pelo usuario.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Compras Dipromed                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION fQuery()

Procregua(2) 
IncProc()

BeginSql Alias "TRB_AG"
	
	COLUMN ZO_DTENTRE AS DATE
	
	Select DISTINCT ZO_CODIGO, ZO_DTENTRE,ZO_HRENTRE,ZO_PCOMPRA,ZO_FORNECE,ZO_LOJA, A2_NREDUZ,ZO_TRANSP,A4_NREDUZ, ZO_CONTATO, ZO_FONECON, ZO_VOLUME
	  From %Table:SZO% SZO
	
	 Inner Join %Table:SA2% SA2 on A2_FILIAL = %xFilial:SA2%
	                             and A2_COD  = ZO_FORNECE
	                             and A2_LOJA = ZO_LOJA
	                             and SA2.%notdel%
	
	Inner Join %Table:SA4% SA4  on A4_FILIAL = %xFilial:SA4%
	                            and A4_COD    = ZO_TRANSP
	                            and SA4.%notdel%
	
	where ZO_FILIAL = %xFilial:SZO%
	  and ZO_DTENTRE between %Exp:MV_PAR01% and %Exp:MV_PAR02%           
      and ZO_STATUS <>'3'
      and SZO.%notdel%
	
	Order By ZO_DTENTRE,ZO_HRENTRE,ZO_FORNECE,ZO_LOJA


EndSql         

IncProc()

Return(!TRB_AG->( EOF().and.BOF()))
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfAjustSX1()บAutor ณJailton B Santos-JBSบ Data ณ 17/07/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria o Grupo de Perguntas no SX1                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEspecifico Compras Dipromed                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ                            ?
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fAjustSX1(cNome)

Local nId_SX1
Local aRegs	:= {}
Local aArea := GetArea()
Local lRet  := .T.
                   
AAdd(aRegs,{"01","Data de                    ","mv_ch1","D",08,0,0,"G","mv_par01","" ,"" ,"",""})
AAdd(aRegs,{"02","Data ate                   ","mv_ch2","D",08,0,0,"G","mv_par02","" ,"" ,"",""})
//AAdd(aRegs,{"02","Transportadora           ","mv_ch1","C",06,0,0,"G","mv_par02","" ,"" ,"","SA4"})
//AAdd(aRegs,{"03","Fornecedor               ","mv_ch1","C",06,0,0,"G","mv_par03","" ,"" ,"","SA2"})

DbSelectArea("SX1")
DbSetOrder(1)

For nId_SX1:=1 to Len(aRegs)

	DbSeek( cPerg + aRegs[nId_SX1][1] )

	If !Found() .or. aRegs[nId_SX1][2]<>X1_PERGUNT    
	
		RecLock("SX1",!Found())
	
		SX1->X1_GRUPO   := cPerg
		SX1->X1_ORDEM   := aRegs[nId_SX1][01]
		SX1->X1_PERGUNT := aRegs[nId_SX1][02]
		SX1->X1_VARIAVL := aRegs[nId_SX1][03]
		SX1->X1_TIPO    := aRegs[nId_SX1][04]
		SX1->X1_TAMANHO := aRegs[nId_SX1][05]
		SX1->X1_DECIMAL := aRegs[nId_SX1][06]
		SX1->X1_PRESEL  := aRegs[nId_SX1][07]
		SX1->X1_GSC     := aRegs[nId_SX1][08]
		SX1->X1_VAR01   := aRegs[nId_SX1][09]
		SX1->X1_DEF01   := aRegs[nId_SX1][10]
		SX1->X1_DEF02   := aRegs[nId_SX1][11]
		SX1->X1_DEF03   := aRegs[nId_SX1][12]
		SX1->X1_F3      := aRegs[nId_SX1][13]
	
		MsUnlock()
	
	Endif

Next nId_SX1
RestArea(aArea)
Return(lRet)   

Static Function fQuebra()

If dDataRel <> TRB_AG->ZO_DTENTRE .and. dDataRel <> cTod('').or.TRB_AG->(EOF())  
   
   fCabec() 
   
   linha++
   @ linha, T_LEN[12,2] psay '------------'
   linha++  
   @ linha, T_LEN[10,2] psay 'Total de Volumes por Dia'
   @ linha, T_LEN[12,2] psay Transform(nTotVol,"@ke 999,999,999")
   linha++  
   nTotVol := 0
EndIf 
  
dDataRel := TRB_AG->ZO_DTENTRE
nTotVol   +=TRB_AG->ZO_VOLUME
nTotVoG += TRB_AG->ZO_VOLUME

Return(.T.)

Static Function fFinal()

If TRB_AG->(EOF())
   
   fCabec() 
   
   linha++
   @ linha, T_LEN[12,2] psay '------------'
   linha++  
   @ linha, T_LEN[10,2] psay 'Total de Volumes por Dia'
   @ linha, T_LEN[12,2] psay Transform(nTotVol,"@ke 999,999,999")
   linha++  

   fCabec()
   
   linha++
   @ linha, T_LEN[12,2] psay '------------'
   linha++  
   @ linha, T_LEN[10,2] psay 'Total Geral'
   @ linha, T_LEN[12,2] psay Transform(nTotVoG,"@ke 999,999,999")
   linha++  
EndIf   

Return(.T.)

Static Function fCabec()

local b_lin   := {|valor,ind| F_Ler_Tab(R_Campos,ind)}
Local tamanho := Adados[5]
Local nAsterisco

Do Case
	Case Tamanho == "P"; nAsterisco := 080
	Case Tamanho == "M"; nAsterisco := 132
	Case Tamanho == "G"; nAsterisco := 220
EndCase                

If Linha>55
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))

	If Empty(cabec1) .And. Empty(cabec2)
		@ PROW()+1,T_Len[1,2]-1 PSAY REPLI('*',nAsterisco)
	Endif             

	Linha:=PROW()+1 ; l_tag:=say_tit
	AEVAL(R_Campos, b_lin)
	Linha++ ; l_tag:=say_rep
	AEVAL(R_Campos, b_lin)
Endif
Return(.T.)