pragma solidity ^0.4.4;

contract prescrip {

    //  Struct Patient
    //  uname - username of the Patient
    //  dataHash - Patient data
    //  rating - rating given to Patient given based on regularity
    //  upvotes - number of upvotes recieved from clinics
    //  clinic - address of clinic that validated the Patient account

    struct Patient {
        string uname;
        string dataHash;
        uint rating;
        uint upvotes;
        address clinic;
        string password;
    }

    //  Struct Clinic
    //  name - name of the clinic/Clinic
    //  ethAddress - ethereum address of the clinic/Clinic
    //  rating - rating based on number of valid/invalid verified accounts
    //  pres_count - number of prescriptions verified by the clinic/Clinic

    struct Clinic {
        string name;
        address ethAddress;
        uint rating;
        uint pres_count;
        string regNumber;
    }

    struct Request {
        string uname;
        address clinicAddress;
        bool isAllowed;
    }

    //  list of all Patients

    Patient[] allPatients;

    //  list of all Clinics

    Clinic[] allOrgs;


    Request[] allRequests;

    function ifAllowed(string Uname, address clinicAddress) public payable returns(bool) {
        for(uint i = 0; i < allRequests.length; ++i) {
            if(stringsEqual(allRequests[i].uname, Uname) && allRequests[i].clinicAddress == clinicAddress && allRequests[i].isAllowed) {
                return true;
            }
        }
        return false;
    }

    function getclinicRequests(string Uname, uint ind) public payable returns(address) {
        uint j = 0;
        for(uint i=0;i<allRequests.length;++i) {
            if(stringsEqual(allRequests[i].uname, Uname) && j == ind && allRequests[i].isAllowed == false) {
                return allRequests[i].clinicAddress;
            }
            j ++;
        }
        return 0x14e041521a40e32ed88b22c0f32469f5406d757a;
    }

    function addRequest(string Uname, address clinicAddress) public payable {
        for(uint i = 0; i < allRequests.length; ++ i) {
            if(stringsEqual(allRequests[i].uname, Uname) && allRequests[i].clinicAddress == clinicAddress) {
                return;
            }
        }
        allRequests.length ++;
        allRequests[allRequests.length - 1] = Request(Uname, clinicAddress, false);
    }

    function allowPharm(string Uname, address clinicAddress, bool ifallowed) public payable {
        for(uint i = 0; i < allRequests.length; ++ i) {
            if(stringsEqual(allRequests[i].uname, Uname) && allRequests[i].clinicAddress == clinicAddress) {
                if(ifallowed) {
                    allRequests[i].isAllowed = true;
                } else {
                    for(uint j=i;j<allRequests.length-2; ++j) {
                        allRequests[i] = allRequests[i+1];
                    }
                    allRequests.length --;
                }
                return;
            }
        }
    }

    //   internal function to compare strings
    
    function stringsEqual(string storage _a, string memory _b) internal returns (bool) {
		bytes storage a = bytes(_a);
		bytes memory b = bytes(_b);
		if (a.length != b.length)
			return false;
		// @todo unroll this loop
		for (uint i = 0; i < a.length; i ++)
        {
			if (a[i] != b[i])
				return false;
        }
		return true;
	}

    //  function to check access rights of transaction request sender

    function isPartOfOrg() public payable returns(bool) {
        for(uint i = 0; i < allOrgs.length; ++ i) {
            if(allOrgs[i].ethAddress == msg.sender)
                return true;
        }
        return false;
    }

    //  function that adds an Clinic to the network
    //  returns 0 if successfull
    //  returns 7 if no access rights to transaction request sender
    //  no check on access rights if network strength in zero

    function addclinic(string uname, address eth, string regNum) public payable returns(uint) {
        if(allOrgs.length == 0 || isPartOfOrg()) {
            allOrgs.length ++;
            allOrgs[allOrgs.length - 1] = Clinic(uname, eth, 200, 0, regNum);
            return 0;
        }

        return 7;
    }

    //  function that removes an Clinic from the network
    //  returns 0 if successful
    //  returns 7 if no access rights to transaction request sender
    //  returns 1 if Clinic to be removed not part of network

    function removeclinic(address eth) public payable returns(uint) {
        if(!isPartOfOrg())
            return 7;
        for(uint i = 0; i < allOrgs.length; ++ i) {
            if(allOrgs[i].ethAddress == eth) {
                for(uint j = i+1;j < allOrgs.length; ++ j) {
                    allOrgs[i-1] = allOrgs[i];
                }
                allOrgs.length --;
                return 0;
            }
        }
        return 1;
    }

    //  function to add a Patient profile to the database
    //  returns 0 if successful
    //  returns 7 if no access rights to transaction request sender
    //  returns 1 if size limit of the database is reached
    //  returns 2 if Patient already in network

    function addPatient(string Uname, string DataHash) public payable returns(uint) {
        if(!isPartOfOrg())
            return 7;
        //  throw error if username already in use
        for(uint i = 0;i < allPatients.length; ++ i) {
            if(stringsEqual(allPatients[i].uname, Uname))
                return 2;
        }
        allPatients.length ++;
        //  throw error if there is overflow in uint
        if(allPatients.length < 1)
            return 1;
        allPatients[allPatients.length-1] = Patient(Uname, DataHash, 100, 0, msg.sender, "null");
        updateRating(msg.sender,true);
        return 0;
    }

    //  function to remove fraudulent Patient profile from the database
    //  returns 0 if successful
    //  returns 7 if no access rights to transaction request sender
    //  returns 1 if Patient profile not in database

    function removePatient(string Uname) public payable returns(uint) {
        if(!isPartOfOrg())
            return 7;
        for(uint i = 0; i < allPatients.length; ++ i) {
            if(stringsEqual(allPatients[i].uname, Uname)) {
                address a = allPatients[i].clinic;
                for(uint j = i+1;j < allPatients.length; ++ j) {
                    allPatients[i-1] = allPatients[i];
                }
                allPatients.length --;
                updateRating(a,false);
                //  updateRating(msg.sender, true);
                return 0;
            }
        }
        //  throw error if uname not found
        return 1;
    }

    //  function to modify a Patient profile in database
    //  returns 0 if successful
    //  returns 7 if no access rights to transaction request sender
    //  returns 1 if Patient profile not in database

    function modifyPatient(string Uname,string DataHash) public payable returns(uint) {
        if(!isPartOfOrg())
            return 7;
        for(uint i = 0; i < allPatients.length; ++ i) {
            if(stringsEqual(allPatients[i].uname, Uname)) {
                allPatients[i].dataHash = DataHash;
                allPatients[i].clinic = msg.sender;
                return 0;
            }
        }
        //  throw error if uname not found
        return 1;
    }

    // function to return Patient profile data

    function viewPatient(string Uname) public payable returns(string) {
        if(!isPartOfOrg())
            return "Access denied!";
        for(uint i = 0; i < allPatients.length; ++ i) {
            if(stringsEqual(allPatients[i].uname, Uname)) {
                return allPatients[i].dataHash;
            }
        }
        return "Patient not found in database!";
    }

    //  function to modify Patient rating

    function updateRatingPatient(string Uname, bool ifIncrease) public payable returns(uint) {
        for(uint i = 0; i < allPatients.length; ++ i) {
            if(stringsEqual(allPatients[i].uname, Uname)) {
                //update rating
                if(ifIncrease) {
                    allPatients[i].upvotes ++;
                    allPatients[i].rating += 100/(allPatients[i].upvotes);
                    if(allPatients[i].rating > 500) {
                        allPatients[i].rating = 500;
                    }
                }
                else {
                    allPatients[i].upvotes --;
                    allPatients[i].rating -= 100/(allPatients[i].upvotes + 1);
                    if(allPatients[i].rating < 0) {
                        allPatients[i].rating = 0;
                    }
                }
                return 0;
            }
        }
        //  throw error if clinic not found
        return 1;
    }

    //  function to update Clinic rating
    //  bool true indicates a succesfull addition of prescription
    //  false indicates detection of a fake prescription

    function updateRating(address clinicAddress,bool ifAdded) public payable returns(uint) {
        for(uint i = 0; i < allOrgs.length; ++ i) {
            if(allOrgs[i].ethAddress == clinicAddress) {
                //update rating
                if(ifAdded) {
                    allOrgs[i].pres_count ++;
                    allOrgs[i].rating += 100/(allOrgs[i].pres_count);
                    if(allOrgs[i].rating > 500) {
                        allOrgs[i].rating = 500;
                    }
                }
                else {
                    //  allOrgs[i].pres_count --;
                    allOrgs[i].rating -= 100/(allOrgs[i].pres_count + 1);
                    if(allOrgs[i].rating < 0) {
                        allOrgs[i].rating = 0;
                    }
                }
                return 0;
            }
        }
        //  throw error if clinic not found
        return 1;
    }

    //  function to validate clinic log in
    //  returns null if username or password not correct
    //  returns clinic name if correct
    function checkclinic(string Uname, address password) public payable returns(string) {
        for(uint i = 0; i < allOrgs.length; ++ i) {
            if(allOrgs[i].ethAddress == password && stringsEqual(allOrgs[i].name, Uname)) {
                return "0";
            }
        }
        return "null";
    }

    function checkPatient(string Uname, string password) public payable returns(bool) {
        for(uint i = 0; i < allPatients.length; ++ i) {
            if(stringsEqual(allPatients[i].uname, Uname) && stringsEqual(allPatients[i].password, password)) {
                return true;
            }
            if(stringsEqual(allPatients[i].uname, Uname)) {
                return false;
            }
        }
        return false;
    }

    function setPassword(string Uname, string password) public payable returns(bool) {
        for(uint i=0;i < allPatients.length; ++ i) {
            if(stringsEqual(allPatients[i].uname, Uname) && stringsEqual(allPatients[i].password, "null")) {
                allPatients[i].password = password;
                return true;
            }
        }
        return false;
    }

    // All getter functions

    function getclinicName(address ethAcc) public payable returns(string) {
        for(uint i = 0; i < allOrgs.length; ++ i) {
            if(allOrgs[i].ethAddress == ethAcc) {
                return allOrgs[i].name;
            }
        }
        return "null";
    }

    function getclinicEth(string uname) public payable returns(address) {
        for(uint i = 0; i < allOrgs.length; ++ i) {
            if(stringsEqual(allOrgs[i].name, uname)) {
                return allOrgs[i].ethAddress;
            }
        }
        return 0x14e041521a40e32ed88b22c0f32469f5406d757a;
    }

    function getPatientclinicName(string Uname) public payable returns(string) {
        for(uint i = 0;i < allPatients.length; ++ i) {
            if(stringsEqual(allPatients[i].uname, Uname)) {
                return getclinicName(allPatients[i].clinic);
            }
        }
    }

    function getclinicReg(address ethAcc) public payable returns(string) {
        for(uint i = 0; i < allOrgs.length; ++ i) {
            if(allOrgs[i].ethAddress == ethAcc) {
                return allOrgs[i].regNumber;
            }
        }
        return "null";
    }

    function getclinicKYC(address ethAcc) public payable returns(uint) {
        for(uint i = 0; i < allOrgs.length; ++ i) {
            if(allOrgs[i].ethAddress == ethAcc) {
                return allOrgs[i].pres_count;
            }
        }
        return 0;
    }

    function getclinicRating(address ethAcc) public payable returns(uint) {
        for(uint i = 0; i < allOrgs.length; ++ i) {
            if(allOrgs[i].ethAddress == ethAcc) {
                return allOrgs[i].rating;
            }
        }
        return 0;
    }

    function getPatientclinicRating(string Uname) public payable returns(uint) {
        for(uint i = 0;i < allPatients.length; ++ i) {
            if(stringsEqual(allPatients[i].uname, Uname)) {
                return getclinicRating(allPatients[i].clinic);
            }
        }
    }

    function getPatientRating(string Uname) public payable returns(uint) {
        for(uint i = 0; i < allPatients.length; ++ i) {
            if(stringsEqual(allPatients[i].uname, Uname)) {
                return allPatients[i].rating;
            }
        }
        return 0;
    }

}