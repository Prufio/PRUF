
        const PRUF_Strings = artifacts.require('Strings2'); 
        
        let Strings;

        contract('Strings', accounts => {
        
            console.log('//**************************BEGIN Strings**************************//')
        
            const account1 = accounts[0];
            const account2 = accounts[1];
            const account3 = accounts[2];
            const account4 = accounts[3];
            const account5 = accounts[4];
            const account6 = accounts[5];
            const account7 = accounts[6];
            const account8 = accounts[7];
            const account9 = accounts[8];
            const account10 = accounts[9];
        
        
            it('Should deploy Strings', async () => {
                const PRUF_Strings_TEST = await PRUF_Strings.deployed({ from: account1 });
                console.log(PRUF_Strings_TEST.address);
                assert(PRUF_Strings_TEST.address !== '');
                Strings = PRUF_Strings_TEST;
            })


            it("Should retrieve tempVal", async () =>{ 
                return Strings.setTempVal()
            })


            it("Should retrieve tempVal", async () =>{ 
                var Record;
                
                return await Strings.getTempVal(function (_err, _result) {
                    if(_err){} 
                    else{Record = _result
                console.log("Record:", Record)}
                })
            })
        });