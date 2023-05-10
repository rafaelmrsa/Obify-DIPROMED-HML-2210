/*                                                              Sao Paulo,  13 Jul 2006
---------------------------------------------------------------------------------------
 Empresa.......: DIPOMED Comércio e Importação Ltda.
 Programa......: DIPM019.PRW
 Objetivo......: Ler o arquivo TXT de ocorrencias fornecidos pela transportadora e atua-
                 lizar o arquivo de SF2 com os dados.  

 Autor.........: Jailton B Santos, JBS
 Data..........: 13 Jul 2006

 Versão........: 2.0
 Consideraçoes.: Função chamada direto do menu ->U_DipM019()
                 Ou scheduler         
Historico                                 
Maximo - Gerando nota fiscal de entrada baseado no CTRC - 21/01/2009
Maximo - Alterando rotina para buscar várias notas em um único CTRC - 22/10/2009
Maximo - Gravando peso original que consta CTRC - 22/10/2009  
                                  
------------------------------------------------------------------------------------
*/
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#DEFINE ENTER CHR(13)+CHR(10)

*---------------------------------------------*
User Function DipM019(aWork)
*---------------------------------------------*
Local _xArea := GetArea()
Private cWorkFlow
Private cWCodEmp   := ""  
Private cWCodFil   := "" 
Private aRecRat    :=  {} //Giovani Zago 14/11/11

//If(cEmpAnt+cFilAnt<>'0404' .And. cEmpAnt+cFilAnt<>'0104') // MCVN - 25/03/10
If !(cEmpAnt$'01/04') // MCVN - 25/05/11 - RBORGES 30/05/14 (Adicionei a HQ no processo do EDI)
	Return
Endif

If ValType(aWork) <> 'A'
	cWorkFlow := "N"   
	cWCodEmp  := cEmpAnt
    cWCodFil  := cFilAnt

    U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 13/12/2005 - Gravando o nome do Programa no SZU
Else
	cWorkFlow := aWork[1] 
	cWCodEmp  := aWork[3]
    cWCodFil  := aWork[4]  
	PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPM019"  TABLES "SF2","SYP","SA2","SZY"
EndIf

ConOut('Integração de EDI (Retorno) - Inicio ...')
Dpm19Retorno()
ConOut('Integração de EDI (Retorno) - Fim ...')

If cWorkFlow == 'S'

    SF2->(dbCloseArea()) 
    SYP->(dbCloseArea()) 
    SA2->(dbCloseArea()) // JBS 29/12/2009
    SZY->(dbCloseArea()) // JBS 29/12/2009
	RESET ENVIRONMENT
EndIf
 
RptStatus({|| D2RatFret(aRecRat)})//Giovani Zago 14/11/11 função para ratear o frete na D2


RestArea(_xArea)
Return(.t.)
                                                                 
*--------------------------------*
static function Dpm19Retorno()
*--------------------------------*

Local lRetorno:=.T.
Local cFile
Local aEstr:={{"OCO001","C",120,0}}
//local cDiretorio:=GetSrvProfString("STARTPATH","")+"EDI\RETORNO\"

// Alterado para gravar arquivos na pasta protheus_data - Por Sandro em 19/11/09. 
Local cDiretorio := "\EDI\RETORNO\"

Local aFiles:=Directory(cDiretorio+"OCO*.txt" )
Local cArquivo:=''
Local id := 1
Local oTempTable

Private cArqEDI := ""  //MCVN - 21/01/2009
private nNotasInt:=0

private aHeader:={}
private aCampos:={} 
private cProblema:=''

/*
cFile:=CriaTrab(aEstr,.T.)
DbUseArea(.T.,,cFile,"INTEG",.F.,.F.)
*/
	If(oTempTable <> NIL)
		oTempTable:Delete()
		oTempTable := NIL
	EndIf
	oTempTable := FWTemporaryTable():New("INTEG")
	oTempTable:SetFields( aEstr )
	oTempTable:Create()

	DbSelectArea("INTEG")

for id := 1 to len(aFiles)

   	cProblema:=''
   	cArquivo:=cDiretorio+aFiles[id,1]
   	cArqIntegrado:=strTran(upper(cArquivo),".TXT",".INT")
   	cArqErros:=strTran(upper(cArquivo),".TXT",".ERR")

   	Dpm19Append(cArquivo,2)
   	Dpm19Integra('OCO',cArquivo)

	RENAME (cArquivo) TO (cArqIntegrado)
    memowrite(cArqErros,cProblema)

 	INTEG->(__dbzap())

next id

INTEG->(E_EraseArq(cFile))

aEstr:={;
{"EMB0001","C",671,0},;
{"EMB0002","C",200,0},;
{"EMB0003","C",200,0},;
{"EMB0004","C",025,0}}

//cDiretorio:=GetSrvProfString("STARTPATH","")+"EDI\RETORNO\"

//Alterado para gravar arquivos na pasta protheus_data - Por Sandro em 19/11/09.
cDiretorio := "\EDI\RETORNO\"

aFiles:=Directory(cDiretorio+"EMB*.txt" )

cArquivo:=''
aHeader:={}
aCampos:={} 

If Select("INTEG") > 0
	INTEG->(DbCloseArea())
EndIf
/*
cFile:=CriaTrab(aEstr,.T.)
DbUseArea(.T.,,cFile,"INTEG",.F.,.F.)
*/

	If(oTempTable <> NIL)
		oTempTable:Delete()
		oTempTable := NIL
	EndIf
	oTempTable := FWTemporaryTable():New("INTEG")
	oTempTable:SetFields( aEstr )
	oTempTable:Create()

	DbSelectArea("INTEG")

for id := 1 to len(aFiles)
    
    cProblema:=''
   	cArquivo:=cDiretorio+aFiles[id,1]
	cArqEDI:=aFiles[id,1] // MCVN - 19/01/2009   
   	cArqErros:=strTran(upper(cArquivo),".TXT",".ERR")
 
   	Dpm19Append(cArquivo,2)

   	If Dpm19Integra('EMB',cArqEDI)
   	    cArqIntegrado:=strTran(upper(cArquivo),".TXT",".INT")
        memowrite(cArqErros,cProblema)
    Else     
   	    cArqIntegrado:=strTran(upper(cArquivo),".TXT",".NAO")
    EndIf
    RENAME (cArquivo) TO (cArqIntegrado)

 	INTEG->(__dbzap())

next id

INTEG->(E_EraseArq(cFile))

Return(Nil)

*---------------------------------------------*
Static Function Dpm19Append(cArquivo,nTipo)
*---------------------------------------------*

local aTipo:={'Ocorrencias','conhecimentos de embarque'}

conout('Integrando arquivo de ' + aTipo[nTipo] + ' ' + cArquivo)
conout('Data..: ' + dtoc(dDataBase) + ' as ' + Time())
conout('Lendo o arquivo de Ocorrencia/conhec de embarque...')
conout('Alias.: ' + Alias() ) // JBS 29/12/2009

DbSelectArea('INTEG')  // JBS 29/12/2009
append from (cArquivo) SDF 

Return(Nil)

*---------------------------------------------*
Static Function Dpm19Integra(cTipo,cArquivo)
*---------------------------------------------*

local cFilSF2 := xFilial('SF2')
local cFilSZY := xFilial('SZY')                                               
local mOcorencia:=''
Local i
Local m

private cCGC
private cNome    
private cDipSerie  
private cDipNotFis 
private aDipSerie  
private aDipNotFis 
private cCodOco 
private cDataOCo
private cHoraOco
private cCodObs 
private Anota  
private cNroConEmb
private cDtEmissao
private dDtEmissao
private nValfrete       
private nValDescFre
private cFreteValor:= ''
private cRemetente := ''
private cDestinata := '' 
Private cFornec    := '' //MCVN - 14/10/2008  
Private cLjForn    := '' //MCVN - 14/10/2008  
Private cTes       := '' //MCVN - 14/10/2008  
Private nIcm       := 0  //MCVN - 14/10/2008  
Private nValor     := 0  //MCVN - 14/10/2008    
private	nBaseIcm   := 0  //MCVN - 15/01/2009  
Private nAliqIcm   := 0  //MCVN - 15/01/2009   
Private nPedagio   := 0  //MCVN - 15/01/2009  
Private cTpFrete   := '' //MCVN - 27/03/2009  
private aDipInfNf  := {} //MCVN - 22/10/2009
private nNfiscal   := 40  //MCVN - 22/10/2009  
private nPositNf   := 233//MCVN - 22/10/2009
private nPositSer  := 238//MCVN - 22/10/2009    
private nSF2ValMer := 0  //MCVN - 22/10/2009 
private nSF2PesoBr := 0  //MCVN - 22/10/2009 
private nPesoCtr   := 0  //MCVN - 22/10/2009   
private nSF2FretSZ3:= 0  //MCVN - 01/11/2009 
private mNotas     := '' //JBS 21/12/2009
private mCTRCGR    := '' //JBS 21/12/2009
private cTipoRec   := 'N' // JBS 21/12/2009 Tipos:'N' -> Gerar NFE, 'R' -> Gerar relatorio
private lEncontrada:= .F. // JBS 11/01/2010 - Determina se a nota foi encontrada
private lTransport := .F. // JBS 11/01/2010 - Determina se o arquivo de Integracao eh valido.
Private cTransp    := ''  // JBS 11/01/2010 - Codigo da transportadora  
Private nCont      := 0 
Private lCont      := .F.  
//Giovani Zago 03/01/12 validação do cnpj na empresa corrente
 If cTipo == 'EMB'
	SF2->(dbSetOrder(1))
	
	INTEG->(dbGotop())
	
	While INTEG->( !EOF() )
		nCont+=1
		
		If SubStr(INTEG->EMB0001,219,14) = "47869078000100" .And. cFilAnt  ="01" .and. nCont = 4 .Or. SubStr(INTEG->EMB0001,219,14) = "47869078000453" .And. cFilAnt  = "04" .and. nCont = 4 .Or.;
     	   SubStr(INTEG->EMB0001,219,14) = "05150878000127" .And. cFilAnt  ="01" .and. nCont = 4
				lCont      := .T.
		EndIf
		
		INTEG->(DbSkip())
	End 
	
	
	If !lCont
		msginfo("Atencao! Processar uma empresa ou filial por vez.")
			INTEG->(DbCloseArea())
		break
		return(.t.)
	EndIf
EndIf

 


//***********************************************************************************************
SF2->(dbSetOrder(1)) 

INTEG->(dbGotop())

Do While INTEG->( !EOF() )

	If cTipo == 'OCO'

        If SubStr(INTEG->OCO001,1,3) == '000'

			cRemetente:=Alltrim(SubStr(INTEG->OCO001,004,035))
			cDestinata:=Alltrim(SubStr(INTEG->OCO001,039,035))
    
        ElseIf SubStr(INTEG->OCO001,1,3) == '321'
	
	        cCGC      :=SubStr(INTEG->OCO001,004,014) 
	
		ElseIf (SubStr(INTEG->OCO001,1,3) == '342'.and.'DIPROMED'$UPPER(cDestinata) .And. ("0104" $ cWCodEmp+cWCodFil)) .or.;
			   (SubStr(INTEG->OCO001,1,3) == '342'.and.'HEALTH'$UPPER(cDestinata)   .And. ("0404" $ cWCodEmp+cWCodFil) .And. cWCodEmp+cWCodFil==cEmpAnt+cFilAnt)		
			cDipSerie :=Alltrim(SubStr(INTEG->OCO001,018,003))
			cDipNotFis:=StrZero(val(SubStr(INTEG->OCO001,021,008)),9)
			cCodOco   :=SubStr(INTEG->OCO001,029,002)
			cDataOCo  :=SubStr(INTEG->OCO001,031,008)
			cHoraOco  :=SubStr(INTEG->OCO001,039,004)
			cCodObs   :=SubStr(INTEG->OCO001,043,002)
			cAnota    :=Alltrim(SubStr(INTEG->OCO001,045,070))
			
			If 'VTR' $ cRemetente .Or. 'MERCURIO' $ cRemetente .Or. 'FASTER' $ cRemetente .Or. 'DVA' $ cRemetente .Or. 'UTILISSIMO' $ cRemetente .Or. ;
			   'PATRUS' $ cRemetente	.Or. 'BRASPRESS' $ cRemetente .Or. 'JAMEF' $ cRemetente	.Or. 'MANN' $ cRemetente .Or. 'TERMACO' $ cRemetente ;
			   .Or. 'ATIVA' $ cRemetente	
			  If ("0404" $ cWCodEmp+cWCodFil)
				    cDipSerie:=If(empty(cDipSerie) .OR. '1' $ cDipSerie .OR. '2' $ cDipSerie,'UNI',cDipSerie)
			    Else 
    			    cDipSerie:=If(empty(cDipSerie) .OR. '1' $ cDipSerie .OR. 'UNI' $ cDipSerie,'2  ',cDipSerie)
			    Endif
			    		    	
		   		If cEmpAnt+cFilAnt = '0404'
			    	cDipSerie:=If(!('004' $ cDipSerie),'004',cDipSerie)
				Else
				    cDipSerie:=If(!('003' $ cDipSerie),'003',cDipSerie)
				Endif                                                  				
				
				
		        If 'VTR' $ cRemetente 
		            cDipNotFis:=StrZero(val(SubStr(INTEG->OCO001,021,008)),9)
		        Endif
            EndIf

 			If !SF2->(dbseek(cFilSF2+cDipNotFis+cDipSerie))     
 			   cProblema += 'Nota Fiscal ' + cDipNotFis + ' serie ' + cDipSerie + ', Não encontrada...'+ ENTER
 			   INTEG->(dbSkip())
               Loop
            EndIf
            
			mOcorencia := SF2->(Trim(StrTran(MSMM(SF2->F2_EDIOCOM,,,,3),"\13\10","")) )
            dDataOCo := ctod(substr(cDataOCo,1,2)+'/'+SubStr(cDataOCo,3,2)+'/'+SubStr(cDataOCo,5,4))
            
			if !Empty(cCodOco)
			    mOcorencia += Tabela("Z1",cCodOco,.f.) + ENTER
                mOcorencia += 'Data da ocorrencia '+dtoc(dDataOCo)+' Hora ' + SubStr(cHoraOco,1,2)+':'+SubStr(cHoraOco,3,2) + ENTER
            endif
			if !Empty(cCodObs)
			    If(cCodObs=='01',mOcorencia += 'Devolução/recusa total' + ENTER,)
			    If(cCodObs=='02',mOcorencia += 'Devolução/recusa parcial' + ENTER,)
			    If(cCodObs=='03',mOcorencia += 'Aceite/entrega por acordo' + ENTER,)
			endIf
			
			if !Empty(cAnota)
			    mOcorencia += cAnota
			endIf
			
			If len(AllTrim(mOcorencia)) > 10
			
				SF2->(Reclock("SF2",.f.))
				
				If Empty(SF2->F2_EDIOCOM)
					SF2->(MSMM(,60,,mOcorencia,1,,,"SF2","F2_EDIOCOM"))
				Else                                                           
				    SF2->(MSMM(SF2->F2_EDIOCOM,,,,2))
					SF2->(MSMM(SF2->F2_EDIOCOM,60,,mOcorencia,4,,,"SF2","F2_EDIOCOM"))
				EndIf
				
				SF2->(MsUnlock("SF2"))
				
			EndIf
			
		EndIf
		
	ElseIf cTipo == 'EMB' 
	  
	  
        If SubStr(INTEG->EMB0001,1,3) == '000'

			cRemetente:=UPPER(Alltrim(SubStr(INTEG->EMB0001,004,035)))
			cDestinata:=UPPER(Alltrim(SubStr(INTEG->EMB0001,039,035)))
	
		ElseIf SubStr(INTEG->EMB0001,1,3) == '321'	
	        
            //----------------------------------------------------------------------
	        //    Identificacao da transportadora
            //----------------------------------------------------------------------
			cCGC  := SubStr(INTEG->EMB0001,004,014)  
			cNome := UPPER(SubStr(INTEG->EMB0001,018,040)) // JBS 07/12/2009
            //----------------------------------------------------------------------
            //    Posiciona a Transportadora pelo CNPJ                                       
            //----------------------------------------------------------------------
            cTransp := ''
            do case
            case 'BRASPRESS'  $ Upper(cNome); cTransp := '000150'
            case 'UTILISSIMO' $ Upper(cNome); cTransp := '003025'
            case 'TERMACO'    $ Upper(cNome); cTransp := '002179' 
            case 'JAMEF'      $ Upper(cNome); cTransp := '000905' 
            case 'MANN'       $ Upper(cNome); cTransp := '102000' 
            case 'ATIVA'      $ Upper(cNome); cTransp := '123455'             
            EndCase
            
            SA4->( DbSetOrder(1))
            If !SA4->( DbSeek(xFilial('SA4') + cTransp ))
                lTransport := .F.
                ConOut('Arquvivo de Integracao ' + cArquivo + ' (Rejeitado) ')
                INTEG->(DbSkip())
                Loop
            EndIf    
            lTransport := .T.
	
		//ElseIf (SubStr(INTEG->EMB0001,1,3) == '322'.and.SubStr(cDestinata,1,8)=='DIPROMED' .and. lTransport .And. ("0104" $ cWCodEmp+cWCodFil)) .OR.;
		  ElseIf (SubStr(INTEG->EMB0001,1,3) == '322'.and. 'DIPROMED'$UPPER(cDestinata) .and. lTransport .And. ("01" $ cWCodEmp) .And. cWCodEmp+cWCodFil==cEmpAnt+cFilAnt ) .OR.; // MCVN - 25/05/11
	             (SubStr(INTEG->EMB0001,1,3) == '322'.and. 'HEALTH'  $UPPER(cDestinata) .and. lTransport .And. ("0401" $ cWCodEmp+cWCodFil) .And. cWCodEmp+cWCodFil==cEmpAnt+cFilAnt)
            cTipoRec   := 'N'  // CTRC normal. Apenas gera NFE. 
   			cCGC       := ''
   			nIcm       := 0
   			nAliqIcm   := 0
   			nBaseIcm   := 0
			nPedagio   := 0
			nNfiscal   := 40    
			aDipInfNf  := {} 
			nPositNf   := 236
			nPositSer  := 233
            nValfrete  := 0    
   		    nValDescFre:= 0
			
			// Tratando Numero do conhecimento de frete para DVA, Mercúrio e Faster  MCVN - 27/07/2007
			If 'DVA' $ cRemetente  .Or. 'MERCURIO' $ cRemetente	.Or. 'FASTER' $ cRemetente	.Or.'UTILISSIMO' $ cRemetente .Or. "IMOLA" $ cRemetente .Or. "MANN" $ cRemetente 
		    	cNroConEmb :=SubStr(INTEG->EMB0001,025,006)                                		    
		    ElseIf 'JAMEF' $ cRemetente .Or. 'TERMACO' $ cRemetente 
			    cNroConEmb :=AllTrim(SubStr(INTEG->EMB0001,019,009))                         
		    ElseIf 'ATIVA' $ cRemetente
			    cNroConEmb :=AllTrim(SubStr(INTEG->EMB0001,022,009))                         		    			    
		    Else
			    cNroConEmb := SubStr(INTEG->EMB0001,019,009)
		    Endif     
		          
		    cCGC       :=SubStr(INTEG->EMB0001,205,014) // MCVN - 21/05/2009                                       
   			//Icms
   			nIcm       :=Val(SubStr(INTEG->EMB0001,081,013)+'.'+SubStr(INTEG->EMB0001,094,002))// MCVN - 15/01/2009  			
   			nAliqIcm   :=Val(SubStr(INTEG->EMB0001,077,002)+'.'+SubStr(INTEG->EMB0001,079,002))// MCVN - 15/01/2009
   			nBaseIcm   :=Val(SubStr(INTEG->EMB0001,062,013)+'.'+SubStr(INTEG->EMB0001,075,002))// MCVN - 15/01/2009
			nPedagio   :=Val(SubStr(INTEG->EMB0001,171,013)+'.'+SubStr(INTEG->EMB0001,184,002))// MCVN - 15/01/2009   			
		    cDtEmissao :=SubStr(INTEG->EMB0001,031,008)
		    cTpFrete   :=SubStr(INTEG->EMB0001,039,001)      //MCVN - 27/03/2009
   		    nPesoCtr   :=Val(SubStr(INTEG->EMB0001,040,005)+'.'+SubStr(INTEG->EMB0001,045,002))  //MCVN - 22/10/2009
		    nValfrete  :=Val(SubStr(INTEG->EMB0001,047,013)+'.'+SubStr(INTEG->EMB0001,060,002)) 
		    nValDescFre:=0 //Desabilitado dia 01/11/2009 - MCVN - nValDescFre:=Val(SubStr(INTEG->EMB0001,081,013)+'.'+SubStr(INTEG->EMB0001,094,002))
            //----------------------------------------------------------------------
            // Se por algum motivo o Conhecimento ja existir  pula para o proximo.
            //----------------------------------------------------------------------
        //    If fExistSZY()
        //       INTEG->(DbSkip())
        //        Loop
        //    EndIf    
            //----------------------------------------------------------------------
		    // Buscando Notas fiscais no arquivo de embarque - 22/10/2009
            //----------------------------------------------------------------------
			For i:=1 to nNfiscal 			    
			    cDipSerie  :=Alltrim(SubStr(INTEG->EMB0001,nPositSer,003))		    	    
			    If 'MANN' $ cRemetente	
				    cDipNotFis :=SubStr(INTEG->EMB0001,nPositNf,009)
			    Else 
				    cDipNotFis :=StrZero(Val(SubStr(INTEG->EMB0001,nPositNf,008)),9)			    
			    Endif
			    If 'VTR' $ cRemetente .Or. 'MERCURIO' $ cRemetente .Or. 'FASTER' $ cRemetente .Or. 'DVA' $ cRemetente .Or. 'PATRUS' $ cRemetente  .Or.; 
			       'UTILISSIMO' $ cRemetente .Or. 'IMOLA' $ cRemetente .Or. 'BRASPRESS' $ cRemetente .Or. 'JAMEF' $ cRemetente .Or.;
			       'MANN' $ cRemetente .Or. 'TERMACO' $ cRemetente .Or. 'ATIVA' $ cRemetente
 	
	
		    	    If ("0404" $ cWCodEmp+cWCodFil) // MCVN - 25/03/10
			    		cDipSerie:=If(empty(cDipSerie) .OR. '1' $ cDipSerie .OR. '2' $ cDipSerie .OR. '0' $ cDipSerie,'UNI',cDipSerie)
			    	Else                                                                                                                
			    		cDipSerie:=If(empty(cDipSerie) .OR. '1' $ cDipSerie .OR. 'UNI' $ cDipSerie .OR. '0' $ cDipSerie,'2  ',cDipSerie)
			    	Endif
			    	
    			    
	   		   		If cEmpAnt+cFilAnt = '0404'
					    cDipSerie:=If(empty(cDipSerie) .OR. !('004' $ cDipSerie),'004',cDipSerie) 
					Else
						cDipSerie:=If(empty(cDipSerie) .OR. !('003' $ cDipSerie),'003',cDipSerie) 
					Endif                                                  				
	
		    	    If 'VTR' $ cRemetente
			        	//cDipNotFis:=StrZero(val(SubStr(INTEG->EMB0001,236,009)),6)
			        	cDipNotFis:= StrZero(Val(SubStr(INTEG->EMB0001,236,008)),9)
			        Endif
	            EndIf
    	    	If cDipNotFis <> '000000000'
	    	    	aAdd( aDipInfNf , { cDipNotFis , cDipSerie } )
	    	    	cDipSerie := ''
   				    cDipNotFis:= ''
				    If 'MANN' $ cRemetente	
   					    nPositNf  += 12
   					    nPositSer += 12
				    Else 
   					    nPositNf  += 11
   					    nPositSer += 11
   					Endif
   				    //nNfiscal++         
   				Else 
   				    i:=40    
   				Endif
		    Next i
	   		//----------------------------------------------------------------
	   		// JBS 07/12/2009 - Localiza o fornecedor pelo CNPJ
	   		//----------------------------------------------------------------
			SA2->(dbSetOrder(3)) 
			If SA2->(!DbSeek(xFilial("SA2")+cCGC)) 
	   		    //------------------------------------------------------------
	   		    // JBS 07/12/2009 - Grava o fornecedor se mesmo não existir
	   		    //------------------------------------------------------------
			    fGravaForne()
			EndIf  
	   		//----------------------------------------------------------------
	   		// JBS 07/12/2009 - Processa o conhecimento do fornecedor
	   		//----------------------------------------------------------------
            nSF2PesoBr := 0
			nSF2ValMer := 0           
			nSF2FretSZ3:= 0       
			cFornec    := SA2->A2_COD
			cLjForn    := SA2->A2_LOJA
			cTes       := If(nIcm > 0,'244','245')
			nValor     := If(nBaseIcm < nValfrete,nBaseIcm,nValfrete) // Se a base de icm for menor que o valor total da nota, utilizo a base de ICM como valor da NFE. 
			nDespesas  := If(nBaseIcm < nValfrete,nPedagio,0)
			dDtemissao := ctod(substr(cDtEmissao,1,2)+'/'+SubStr(cDtEmissao,3,2)+'/'+SubStr(cDtEmissao,5,4))
						
			// Gera NF somente para Imola, Utilissimo e Patrus  MCVN - 21/01/2009                                    
			//If('PATRUS' $ cRemetente  .Or. 'UTILISSIMO' $ cRemetente .Or. 'IMOLA' $ cRemetente .Or. 'BRASPRESS' $ cRemetente) .And. cTpFrete $ 'CI' // Gera nf somente se o frete for CIF ou INCLUSO 27/03/2009
			// JBS 21/12/2009 DIP19NFE()                                                                         
			//EndIf
                 
            // Busca total da mercadoria (Somando valmerc das nfs do ctrc
			
            If Len(aDipInfNf) > 1 
            	TotValMerc()        
            Endif
        	//---------------------------------------------------------------------
            // Criacao da variavel memo que guarda as informacoes dos CTRCs
            // gravados nas notas
        	//---------------------------------------------------------------------
            mCtrcGr:= 'Nota Fiscal  Transp CTRC Gravado Peso CTRC gravado Valor Frete Dip  ' + chr(13) + chr(10) 
            mCtrcGr+= '-----------  ------ ------------ ----------------- -----------------' + chr(13) + chr(10)
        	//---------------------------------------------------------------------
            // Criacao da variavel memo que guarda as informacoes das notas fiscais
            // realcionadas com o CTRC.
        	//---------------------------------------------------------------------
            mNotas := 'Notas Fiscais Relacionadas com o conhecimento: '      // JBS 21/12/2009
            cSeparador := ''  // Separador entre notas fiscais               // JBS 21/12/2009
        	//---------------------------------------------------------------------
            // Grava Informacoes do Conhecimento na Nota Fiscal
        	//---------------------------------------------------------------------
   	        For i:=1 to Len(aDipInfNf) 
   	        
                Begin Sequence  // JBS 21/12/2009
                
	 			If !SF2->(dbseek(cFilSF2+aDipInfNf[i][1]+aDipInfNf[i][2]))     
 				    cProblema += 'Nota Fiscal '+aDipInfNf[i][1]+' serie '+aDipInfNf[i][2]+', Não encontrada...' + ENTER
 				    lEncontrada:= .F. // Nao encontrou a nota fiscal - JBS 11/01/2010
    	            Break
	            EndIf
                lEncontrada:= .T. // Nota fiscal encontrada - JBS 11/01/2010
				mOcorencia := SF2->(Trim(StrTran(MSMM(SF2->F2_EDIOCOM,,,,3),"\13\10","")))
        	    // JBS 11/01/2010 - dDtemissao := ctod(substr(cDtEmissao,1,2)+'/'+SubStr(cDtEmissao,3,2)+'/'+SubStr(cDtEmissao,5,4)) 
        	    //---------------------------------------------------------------------
                // Relaciona as notas fiscais de saida pertencentes ao conhecimento
        	    //---------------------------------------------------------------------
   				mNotas += cSeparador + AllTrim(aDipInfNf[i][1]) +'-'+ AllTrim(aDipInfNf[i][2]) // JBS 21/12/2009
	            cSeparador := ', '  // Seperador de notas                                        // JBS 21/12/2009

    	        cFreteValor := ''
 
	            Do Case
            	Case SF2->F2_TPFRETE == 'I';cFreteValor += 'Frete Incluso R$ '
        	    Case SF2->F2_TPFRETE == 'C';cFreteValor += 'Frete CIF     R$ '  
    	        Case SF2->F2_TPFRETE == 'F';cFreteValor += 'Frete FOB     R$ '  
	            EndCase
 
            	cFreteValor += AllTrim(Transform(nValfrete,"@e 999,999,999.99"))
        	
    	        If nValDescFre > 0 .and. 'BRASPRESS' $ cRemetente
	                cFreteValor += ' -  ' +AllTrim(Transform(nValDescFre,"@e 999,999,999.99")) + ' (desc ICMS Sit Trib)  = ' + Transform(nValfrete - nValDescFre,"@e 999,999,999.99")
				EndIf
			
				If !Empty(cNroConEmb)
				    mOcorencia += 'Conhecimento de embarque ' + AllTrim(cNroConEmb) +' emissao ' + dtoc(dDtEmissao) + ENTER
				    mOcorencia += cFreteValor + ENTER
				EndIf
				
				SF2->(Reclock("SF2",.f.)) 

				If Empty(SF2->F2_NROCON)  // Conhecimento ainda nao preenchido
				    SF2->F2_NROCON := cNroConEmb			
  			        SF2->F2_PESOCTR:= If(Len(aDipInfNf)>1,SF2->F2_PBRUTO/nSF2PesoBr*(nPesoCTR),nPesoCTR)
  				    If len(AllTrim(mOcorencia)) > 10
					    If Empty(SF2->F2_EDIOCOM)
				  	      	SF2->(MSMM(,60,,mOcorencia,1,,,"SF2","F2_EDIOCOM"))
					    Else
				   	        SF2->(MSMM(SF2->F2_EDIOCOM,,,,2))
				   		    SF2->(MSMM(SF2->F2_EDIOCOM,60,,mOcorencia,4,,,"SF2","F2_EDIOCOM"))
					    EndIf
					EndIf
  			    Else // Conhecimento ja preenchido   
  				    If len(AllTrim(mOcorencia)) > 10
				     	If Empty(SF2->F2_EDIOCOM)
				  	    	SF2->(MSMM(,60,,mOcorencia,1,,,"SF2","F2_EDIOCOM"))
					    Else
				   	        SF2->(MSMM(SF2->F2_EDIOCOM,,,,2))
				   		    SF2->(MSMM(SF2->F2_EDIOCOM,60,,mOcorencia,4,,,"SF2","F2_EDIOCOM"))
					    EndIf
				    EndIf                                       
				    //------------------------------------------------------
                    // Monta a relacao de CTRCs gravados na nota
				    //------------------------------------------------------
                    mCtrcGr+= Padr(AllTrim(SF2->F2_DOC)  + '-' + SF2->F2_SERIE,12) + ' ' +;
                              SF2->F2_TRANSP +' ' +;
                              Padr(SF2->F2_NROCON,12) +' ' +;
                              Transform(SF2->F2_PESOCTR,"@ke 999,999,999.9999" ) +;
                              Transform(SF2->F2_FRTDIP ,"@ke 999,999,999.9999" ) + chr(13)+chr(10)
                
                    SF2->( MsUnlock("SF2") )
   			
                    cTipoRec := 'R'  // Determina que esta informacao deve aparecer no relatorio
                    
   				    Break // JBS 21/12/2009
			
				EndIf 
				                                                             				   	
				SD2->(DbSetOrder(3))// Definindo a Ordem
				SD2->(dbseek(cFilSF2+aDipInfNf[i][1]+aDipInfNf[i][2])) // Posicionando SD2
				SC5->(dbseek(cFilSF2+SD2->D2_PEDIDO)) // Posicionando SC5 

				// Atualiza campo de F2_FRETSZ3 CALCULO DO FRETE SOBRE O PESO CTRC 				    
				U_ClcLimite("NF",SF2->F2_VALBRUT,If(Len(aDipInfNf)>1,SF2->F2_PBRUTO/nSF2PesoBr*(nPesoCTR),nPesoCTR))  // Atualiza campo de F2_FRETSZ3 CALCULO DO FRETE SOBRE O PESO CTRC                             
			
				SF2->(MsUnlock("SF2"))
				nSF2FretSZ3+=SF2->F2_FRETSZ3 
			
				End Sequence // JBS 21/12/2009
	   		
	   		Next i
            //---------------------------------------------------------
            // Grava as informacoes do CTRC na tabela 'SZY'
            //---------------------------------------------------------
            //fGrvSZY(cArquivo)  Desabilitado dia 22/06/2022
            //---------------------------------------------------------
            //Rateia frete do CTRC baseado no F2_FRETSZ3 se necessario
            //---------------------------------------------------------
   		    For m:=1 to Len(aDipInfNf) 
	 			If SF2->( Dbseek(cFilSF2+aDipInfNf[m][1]+aDipInfNf[m][2]) )     
    		        //---------------------------------------------------------	   		    
	   		        // Rateia frete do CTRC baseado no F2_FRETSZ3 se necessario
    		        //---------------------------------------------------------	   		    
   				    If SF2->F2_TPFRETE $ 'CI' .and.; // Só atualiza o Frete se o tipo for CIF ou Incluso.
				        SF2->F2_FRTDIP = 0            // Valor do Frete Ainda não preenchido			    	   		    	
	    		        SF2->( Reclock("SF2",.F.))    
				        SF2->F2_FRTDIP := If(Len(aDipInfNf)>1,SF2->F2_FRETSZ3/nSF2FretSZ3*(nValfrete - If('BRASPRESS' $ cRemetente, nValDescFre, 0 )),nValfrete - If('BRASPRESS' $ cRemetente, nValDescFre, 0 ))
				        AADD(aRecRat,{cValToChar(SF2->(Recno()))})  //Giovani Zago 14/11/11
				        SF2->(MsUnlock("SF2"))
				    EndIf
	 			Else
 			        cProblema += 'Nota Fiscal '+aDipInfNf[m][1]+' serie '+aDipInfNf[m][2]+', Não encontrada...' + ENTER
    		    EndIf
    		    		   
			Next m  
		EndIf 
		EndIf
	
	INTEG->( DbSkip() )

EndDo

Return(lTransport)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TotValMercº Autor ³ Maximo Canuto V. N.º Data ³  22/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Soma Peso e valor da mercadoria das notas que estão no     º±±
±±º          ³ mesmo CTRC                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Dipromed                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteracoes³ Data       Autor             Motivo                        º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TotValMerc()

Local _xAlias   := GetArea()  
Local QRY1      := ''
Local i

For i:=1 to Len(aDipInfNf) 

	QRY1 := " SELECT F2_VALMERC, F2_PBRUTO  "
	QRY1 += " FROM " + RetSQLName("SF2")
	QRY1 += " WHERE F2_DOC =  '" +aDipInfNf[i][1]+"'"
	QRY1 += " AND F2_SERIE =  '" +aDipInfNf[i][2]+"'"
	QRY1 += " AND " + RetSQLName("SF2") + ".D_E_L_E_T_ = ''"                          
	// Processa Query SQL
	DbCommitAll()
	TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query

	DbSelectArea("QRY1") 
	QRY1->(DbGoTop())  	
	
	nSF2ValMer += QRY1->F2_VALMERC
	nSF2PesoBr += QRY1->F2_PBRUTO
	
	dbSelectArea("QRY1")
	
	QRY1->(dbCloseArea()) 	
	
Next i

RestArea(_xAlias)

Return                                                            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGravaForneºAutor  ³Jailton B Santos-JBSº Data ³ 07/12/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Função desenvolvida para gravar o fornecedor informado no º±±
±±º          ³  conhecimento de embarque e que não existe no cadastro de  º±±
±±º          ³  fornecedor.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³  EDI - Dipromed                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGravaForne()

Local nRecno  := 0
Local cLoja   := ''
Local cFornece:= ''
Local lRet    := .T.
Local cFilSA2 := xFilial('SA2')
Local cPrfix  := SubStr(cCgc,1,8)
Local cCodFor := Alltrim(GetMv("MV_DIPM19A"))

SA2->(dbGoTop())
//--------------------------------------------------------------
// Procura se existe outros fornecedores com mesmo prefixo do 
// CNPJ, o que indicaria a existencia de filiais.
//--------------------------------------------------------------
SA2->(dbSeek(cFilSA2 + cPrfix))

If SubStr(SA2->A2_CGC,1,8) == cPrfix

	cFornece := SA2->A2_COD
	cLoja    := SA2->A2_LOJA

	M->A2_NOME   := SA2->A2_NOME
	M->A2_NREDUZ := SA2->A2_NREDUZ

	//------------------------------------------------------
	// Determina o codigo da proxima loja a ser criada
	//------------------------------------------------------
	SA2->(dbSetOrder(1))

	Do While SA2->(dbSeek(cFilSA2 + cFornece+cLoja))
		cLoja := StrZero(val(cLoja)+1,2)
	EndDo
	
	SA2->(RecLock('SA2',.t.))
	SA2->A2_FILIAL  := cFilSA2
	SA2->A2_COD     := cFornece
	SA2->A2_LOJA    := cLoja
	SA2->A2_NOME    := M->A2_NOME
	SA2->A2_NREDUZ  := M->A2_NREDUZ
	SA2->A2_CGC     := cCgc 
	SA2->A2_NATUREZ := 'P331132'
	SA2->(MsUnlock('SA2'))  

Else
    //---------------------------------------------------- 
    // Se não existir o prefixo cadastrado
    // cria um novo codigo de fornecedor
    //---------------------------------------------------- 
	cLoja    := '01'
    SA2->(dbSetOrder(1))
    
    Do While SA2->(DbSeek(cFilSA2+cCodFor+cLoja))
        cCodFor := StrZero(val(cCodFor)+1,6)
    EndDo
        
	SA2->(RecLock('SA2',.t.))
	SA2->A2_FILIAL  := cFilSA2
	SA2->A2_COD     := cCodFor
	SA2->A2_LOJA    := cLoja
	SA2->A2_NOME    := cNome
	SA2->A2_NREDUZ  := cNome
	SA2->A2_CGC     := cCgc
	SA2->A2_NATUREZ := 'P331132'
	SA2->(MsUnlock('SA2'))  
    //---------------------------------------------------
    // Grava o codigo de fornecedor encontado no SX6
    //---------------------------------------------------
    SetMv("MV_DIPM19A",cCodFor)
	
EndIf                                     
//-------------------------------------------------------
// Determina que na troca da ordem para o CNPJ, a tabela
// permaneça posicionada no mesmo registro.
//-------------------------------------------------------
nRecno := SA2->(Recno())
SA2->(dbSetOrder(3))
SA2->(DbGoTo(nRecno))
//-------------------------------------------------------
// Envia e-mail para o usuario responsavel pelo cadastro 
// de fornecedores.   
//-------------------------------------------------------
fEmail()

Return(lRet) 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fEmail()  º Autor ³Jailton B Santos-JBSº Data ³  07/12/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Funcao desenvolvida para enviar um e-mail para o usuario  º±±
±±º          ³  respponsavel pelo cadastro de fornecedores. Informando-o  º±±
±±º          ³  que foi incluido parcialmente um fornecedor e que o usua- º±±
±±º          ³  rio precisa concluir o cadastro do fornecedor             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ EDI - Dipromed                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fEmail()

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := Alltrim(GetMv("MV_DIPM019"))
Local cError    := ""
Local cMsg      := ""
Local lResult   := .F.
Local cAssunto  := 'Completar Cad Fornecedor : ' +  cCGC + ' Cod : '+SA2->A2_COD + ' Loja: ' + SA2->A2_LOJA                                             
Local cEmailCc  := ""
Local cEmailBcc := ""  
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.

cMsg := '<html>'
cMsg += '<head>'
cMsg += '<title>' + cAssunto + '</title>'
cMsg += '</head>'
cMsg += '<body>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'

cMsg += '<table width="100%" border="1">'
cMsg += '<tr align="center">'
cMsg += '<td width="100%" colspan="10"><font color="red" size="4">' + cAssunto + '</font></td>'
cMsg += '</tr>'

cMsg += '<tr align="center">'
cMsg += '<td width="100%" colspan="10"><font color="red" size="2">CNPJ: <font color="blue" size="2">' + SA2->A2_CGC + '<font color="red" size="2"></td>'
cMsg += '</font>'
cMsg += '</tr>'

cMsg += '<tr align="center">'
cMsg += '<td width="10%"><font color="red" size="2">Codigo: '       + SA2->A2_COD    + '</td>'
cMsg += '<td width="10%"><font color="red" size="2">Loja: '         + SA2->A2_LOJA   + '</td>'
cMsg += '<td width="40%"><font color="red" size="2">Razão Social: ' + SA2->A2_NOME   + '</td>'
cMsg += '<td width="25%"><font color="red" size="2">Nome Reduzido: '+ SA2->A2_NREDUZ + '</td>'
cMsg += '<td width="15%"><font color="red" size="2">CNPJ: '         + SA2->A2_CGC    + '</td>'
cMsg += '</font>'
cMsg += '</tr>'

cMsg += '<tr align="center">'
cMsg += '<td colspan="10"><font color="red" size="3">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="red" size="1">(DIPM019.PRW)</td>'
cMsg += '</tr>'

cMsg += '</table>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '</body>'
cMsg += '</html>'

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

If !lAutOk
	If ( lSmtpAuth )
		lAutOk := MailAuth(cAccount,cPassword)
	Else
		lAutOk := .T.
	EndIf
EndIf

If lResult .And. lAutOk

	SEND MAIL FROM cFrom ;
	TO      	Lower(cEmailTo);
	CC      	Lower(cEmailCc);
	BCC     	Lower(cEmailBcc);
	SUBJECT 	cAssunto;
	BODY    	cMsg;
	RESULT lResult
	
	If !lResult
		//Erro no envio do email
		GET MAIL ERROR cError		
		MsgInfo(cError,OemToAnsi("Atenção"))
	EndIf
	
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	
	MsgInfo(cError,OemToAnsi("Atenção"))
EndIf

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGrvLog   ºAutor  ³Jailton B Santos-JBSº Data ³  15/12/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao criada para gravar um arquivo de log na atualizacao  º±±
±±º          ³do SF2 quando a nota ja possuir CTRC.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ EDI - Dipromed                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGrvLog(cString)

Local lRet  := .T.
Local cFile := 'LOG_CTRC.LOG'

If !File('\EDI\RETORNO\LOG')
	MakeDir('\EDI\RETORNO\LOG')
EndIf

If !File("\EDI\RETORNO\LOG\" + cFile)
	nHandle := MsfCreate("\EDI\RETORNO\LOG\" + cFile,0)
Else
	nHandle := FOpen("\EDI\RETORNO\LOG\" + cFile,2)
	fSeek(nHandle,0,2)
EndIf
If nHandle > 0         
	FWrite(nHandle,cString + Chr(13) + Chr(10)) 
    FClose(nHandle)
EndIf
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGrvSZY() ºAutor  ³Jailton B Santos-JBSº Data ³ 21/12/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava as informacoes de cada CTRC na Tabela SZY para depois º±±
±±º          ³na rotina de geracao de NFE o usuario selecionar os CTRCs   º±±
±±º          ³que deverao compor cada nota fiscal de entrada.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FAT - Dipromed                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGrvSZY(cArquivo)

Local lRet := .T.

SZY->( RecLock('SZY', .T.) )
SZY->ZY_FILIAL  := xFilial('SZY')
SZY->ZY_CTRC    := cNroConEmb
SZY->ZY_TRANSP  := SA4->A4_COD
SZY->ZY_DTEMIS  := CtoD(substr(cDtEmissao,1,2) + '/' + SubStr(cDtEmissao,3,2) + '/' + SubStr(cDtEmissao,5,4))
SZY->ZY_REMETE  := cRemetente
SZY->ZY_DESTIN  := cDestinata
SZY->ZY_CGC     := cCGC
SZY->ZY_ICM     := nIcm
SZY->ZY_AICM    := nAliqIcm
SZY->ZY_BCICM   := nBaseIcm
SZY->ZY_PEDAGI  := nPedagio
SZY->ZY_FRET    := cTpFrete
SZY->ZY_PESOCTR := nPesoCtr
SZY->ZY_VALFRE  := nValfrete
SZY->ZY_VALDFR  := nValDescFre
SZY->ZY_NOTAS   := mNotas
SZY->ZY_CTRCGR  := mCTRCGR 
SZY->ZY_TIPOREC := cTipoRec
SZY->ZY_NOMEEDI := cArquivo
SZY->ZY_STATUS  := 'I' // 'I' -> Integrado, 'G' -> Gerado NFE   
SZY->ZY_SERIE   := If(SZY->ZY_TRANSP == '000150',"U1",If(SZY->ZY_TRANSP == '000905','UNI',If(SZY->ZY_TRANSP == '123455','16',"")))
SZY->(MsUnLock('SZY'))

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fExistSZY()ºAutor ³Jailton B Santos-JBSº Data ³ 29/12/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o CTRC ja esta gravado para evitar duplicidade º±±
±±º          ³ de gravacao na tabela SZY.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FAT - Dipromed                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fExistSZY()
Local lRet := .F. 
lRet := SZY->( DbSeek( xFilial('SZY') + SA4->A4_COD + cNroConEmb) )
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  D2RatFret()ºAutor ³Giovani Zago           Data ³ 14/11/2011   ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rateia o frete nos itens de cada nota                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FAT - Dipromed                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function D2RatFret(aRecRat) 

Local i        := 1
Local _cExc    := ""
Local aError   :={}
Local cEmail   := "maximo.canuto@dipromed.com.br"
Local cAssunto := "Erro No Rateio de Frete "
Local cAttach  := ""
Local cDe      := ""
Local cFuncSent:= "Dipm019.prw"



For i :=1 To Len(aRecRat)
	TcCommit(1)
	_cExc:=" UPDATE "+RetSqlName("SD2")
	_cExc+=" SET D2_FRTDIP = CONVERT(DECIMAL(10,3),Round((D2_TOTAL/F2_VALMERC*F2_FRTDIP),3))
	_cExc+=" FROM "+RetSqlName("SD2")+" SD2 , "+RetSqlName("SF2")+" SF2 "
	_cExc+=" WHERE SD2.D_E_L_E_T_  = ''
	_cExc+=" AND   SF2.D_E_L_E_T_  = ''
	_cExc+=" AND    F2_DOC         = D2_DOC
	_cExc+=" AND    F2_SERIE       = D2_SERIE
	_cExc+=" AND   SF2.R_E_C_N_O_  = "+aRecRat[i][1] 
	_cExc+=" AND    F2_FRTDIP      > 0
	_cExc+=" AND    D2_FRTDIP      = 0
	_cExc+=" AND    F2_FILIAL      = '"+xFilial("SD2")+"'"
	_cExc+=" AND    D2_FILIAL      = '"+xFilial("SF2")+"'"

	If TcSqlExec(_cExc) < 0
	   Aadd(aError,{"Documento","teste"})
	   Aadd(aError,{"Serie"    ,SF2->F2_SERIE})
	   Aadd(aError,{"************","*********************"})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³RollBack da transacao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TcCommit(3)
	
		
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Confirma as transacoes³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TcCommit(2)
		TcCommit(4)
		MsUnlockAll()
	EndIf
Next i

If Len(aError)>0

U_UEnvMail(cEmail,cAssunto,aError,cAttach,cDe,cFuncSent)

EndIf

Return()
