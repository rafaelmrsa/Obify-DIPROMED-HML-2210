User Function TSTJOB()
    
    
    Local aParam := {'01','04'}
    RpcSetType(3)
	RpcSetEnv(aParam[1],aParam[2],,,"FAT")
    U_DipExcRes(aParam)
    //TMSME05(1)
    //U_MyBxMail()
    

    RpcClearEnv()



    //U_DipM019J({'N','01','04'})
Return 
