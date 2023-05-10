/*=================================================================+
|Funcao: FA050GRV |  Autor: Reginaldo Borges |  Data: 18/04/2016  |
+-----------------------------------------------------------------+
|Ponto: Após a gravação de todos os dados e antes da              |
|       contabilização da inclusão do título.                     |
+-----------------------------------------------------------------+
|Observações: Utilizado para gravação de dados complementares.    |
+=================================================================*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

User Function FA050GRV()
_AreaE2 :=SE2->(Getarea())

If Funname()=="FINA050" .Or. Funname()=="FINA750"
	
	_cNum    := SE2->E2_PREFIXO+Alltrim(SE2->E2_NUM)
	_cUsua   := U_DipUsr()
	_nVlcof  := SE2->E2_COFINS
	_nVlIr   := SE2->E2_IRRF
	_nVlcsll := SE2->E2_CSLL
	_nVlpis  := SE2->E2_PIS 
	_nVliss  := SE2->E2_ISS  
	_nVlinss := SE2->E2_INSS	
	
	If SE2->E2_ISS>0 .Or. SE2->E2_INSS>0 .Or. SE2->E2_IRRF>0 .Or. SE2->E2_PIS>0 .Or.;
		SE2->E2_COFINS>0 .Or. SE2->E2_CSLL>0
		
		While !SE2->(Eof()) .And. _cNum==SE2->E2_PREFIXO+Alltrim(SE2->E2_NUM)
			If Empty(SE2->E2_NUM)
				SE2->(Dbskip())
				Loop
			Endif
			
			If (SE2->E2_TIPO=="IRF" .Or. Alltrim(SE2->E2_TIPO)=="TX") .And. _nVlIr==SE2->E2_VALOR .And. ALLTRIM(SE2->E2_NATUREZ) == "P211405"  //IR
				SE2->(Reclock("SE2",.F.))
				SE2->E2_USUARIO := _cUsua
				Msunlock()
			ElseIf Alltrim(SE2->E2_TIPO)=="TX" .And. _nVlpis==SE2->E2_VALOR .And. ALLTRIM(SE2->E2_NATUREZ) == "PIS" //PIS
				SE2->(Reclock("SE2",.F.))
				SE2->E2_USUARIO := _cUsua
				Msunlock()
			ElseIf Alltrim(SE2->E2_TIPO)=="TX" .And. _nVlcof==SE2->E2_VALOR .And. ALLTRIM(SE2->E2_NATUREZ) == "COFINS" //COFINS
				SE2->(Reclock("SE2",.F.))
				SE2->E2_USUARIO := _cUsua
				Msunlock()
			ElseIf Alltrim(SE2->E2_TIPO)=="TX" .And. _nVlcsll==SE2->E2_VALOR .And. ALLTRIM(SE2->E2_NATUREZ) == "CSLL" //CSLL
				SE2->(Reclock("SE2",.F.))
				SE2->E2_USUARIO := _cUsua
				Msunlock()
			ElseIf Alltrim(SE2->E2_TIPO)=="INS" .And. _nVlinss==SE2->E2_VALOR .And. ALLTRIM(SE2->E2_NATUREZ) == "INSS" //INSS
				SE2->(Reclock("SE2",.F.))
				SE2->E2_USUARIO := _cUsua
				Msunlock()				
			ElseIf Alltrim(SE2->E2_TIPO)=="ISS" .And. _nVliss==SE2->E2_VALOR .And. ALLTRIM(SE2->E2_NATUREZ) == "P211510" //ISS
				SE2->(Reclock("SE2",.F.))
				SE2->E2_USUARIO := _cUsua
				Msunlock()								
			Endif
			
			SE2->(Dbskip())
			
		End
	Endif
Endif
Restarea(_AreaE2)

Return
