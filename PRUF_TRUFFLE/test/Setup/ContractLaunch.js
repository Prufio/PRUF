/*--------------------------------------------------------PRüF0.9.0
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\__/\\ ___/\\\\\\\\\\\\\\\        
__\/\\\/////////\\\ _/\\\///////\\\ ____\//__\//____\/\\\///////////__       
___\/\\\_______\/\\\_\/\\\_____\/\\\ ________________\/\\\ ____________      
____\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\_\/\\\\\\\\\\\ ____     
_____\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\_\/\\\///////______
______\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\_\/\\\ ____________
_______\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\_\/\\\ ____________
________\/\\\ ____________\/\\\ _____\//\\\_\//\\\\\\\\\ _\/\\\ ____________
_________\/// _____________\/// _______\/// __\///////// __\/// _____________
*---------------------------------------------------------------------------*/

const PRUF_STOR = artifacts.require("STOR");
const PRUF_UTIL_TKN = artifacts.require("UTIL_TKN");
const PRUF_A_TKN = artifacts.require("A_TKN");
const PRUF_NODE_TKN = artifacts.require("NODE_TKN");
const PRUF_NODE_MGR = artifacts.require("NODE_MGR");
const PRUF_NODE_BLDR = artifacts.require("NODE_BLDR");
const PRUF_NODE_STOR = artifacts.require("NODE_STOR");
const PRUF_APP_NC = artifacts.require("APP_NC");
const PRUF_DAO = artifacts.require("DAO");
const PRUF_DAO_A = artifacts.require("DAO_LAYER_A");
const PRUF_DAO_B = artifacts.require("DAO_LAYER_B");
const PRUF_HELPER = artifacts.require("Helper");
const PRUF_CLOCK = artifacts.require("FAKE_CLOCK");

let STOR;
let UTIL_TKN;
let A_TKN;
let NODE_TKN;
let NODE_MGR;
let NODE_BLDR;
let NODE_STOR;
let APP_NC;
let DAO;
let DAO_A;
let Helper;

let payableRoleB32;
let minterRoleB32;
let trustedAgentRoleB32;
let IDminterRoleB32;
let IDverifierRoleB32;
let assetTransferRoleB32;
let discardRoleB32;
let DAOroleB32;
let DAOcontrollerRoleB32;
let DAOlayerRoleB32;
let DAOadminRoleB32;
let contractAdminRoleB32;
let defaultAdminRoleB32;
let pauserRoleB32;
let roleMemberCount;
let stakeRoleB32;
let stakePayerRoleB32;
let stakeAdminRoleB32;

contract("Launch", (accounts) => {
  console.log(
    "//**************************BEGIN Launch**************************//"
  );

  const account1 = accounts[0];

  it("Should deploy Storage", async () => {
    const PRUF_STOR_TEST = await PRUF_STOR.deployed({ from: account1 });
    console.log(PRUF_STOR_TEST.address);
    assert(PRUF_STOR_TEST.address !== "");
    STOR = PRUF_STOR_TEST;
  });

  it("Should deploy UTIL_TKN", async () => {
    const PRUF_UTIL_TKN_TEST = await PRUF_UTIL_TKN.deployed({ from: account1 });
    console.log(PRUF_UTIL_TKN_TEST.address);
    assert(PRUF_UTIL_TKN_TEST.address !== "");
    UTIL_TKN = PRUF_UTIL_TKN_TEST;
  });

  it("Should deploy PRUF_A_TKN", async () => {
    const PRUF_A_TKN_TEST = await PRUF_A_TKN.deployed({ from: account1 });
    console.log(PRUF_A_TKN_TEST.address);
    assert(PRUF_A_TKN_TEST.address !== "");
    A_TKN = PRUF_A_TKN_TEST;
  });

  it("Should deploy PRUF_NODE_TKN", async () => {
    const PRUF_NODE_TKN_TEST = await PRUF_NODE_TKN.deployed({ from: account1 });
    console.log(PRUF_NODE_TKN_TEST.address);
    assert(PRUF_NODE_TKN_TEST.address !== "");
    NODE_TKN = PRUF_NODE_TKN_TEST;
  });

  it("Should deploy PRUF_NODE_MGR", async () => {
    const PRUF_NODE_MGR_TEST = await PRUF_NODE_MGR.deployed({ from: account1 });
    console.log(PRUF_NODE_MGR_TEST.address);
    assert(PRUF_NODE_MGR_TEST.address !== "");
    NODE_MGR = PRUF_NODE_MGR_TEST;
  });

  it("Should deploy PRUF_APP_NC", async () => {
    const PRUF_APP_NC_TEST = await PRUF_APP_NC.deployed({ from: account1 });
    console.log(PRUF_APP_NC_TEST.address);
    assert(PRUF_APP_NC_TEST.address !== "");
    APP_NC = PRUF_APP_NC_TEST;
  });

  it("Should deploy PRUF_HELPER", async () => {
    const PRUF_HELPER_TEST = await PRUF_HELPER.deployed({ from: account1 });
    console.log(PRUF_HELPER_TEST.address);
    assert(PRUF_HELPER_TEST.address !== "");
    Helper = PRUF_HELPER_TEST;
  });

  it("Should deploy PRUF_DAO_A", async () => {
    const PRUF_DAO_A_TEST = await PRUF_DAO_A.deployed({ from: account1 });
    console.log(PRUF_DAO_A_TEST.address);
    assert(PRUF_DAO_A_TEST.address !== "");
    DAO_A = PRUF_DAO_A_TEST;
  });

  it("Should deploy PRUF_DAO_B", async () => {
    const PRUF_DAO_B_TEST = await PRUF_DAO_B.deployed({ from: account1 });
    console.log(PRUF_DAO_B_TEST.address);
    assert(PRUF_DAO_B_TEST.address !== "");
    DAO_B = PRUF_DAO_B_TEST;
  });

  it("Should deploy PRUF_DAO", async () => {
    const PRUF_DAO_TEST = await PRUF_DAO.deployed({ from: account1 });
    console.log(PRUF_DAO_TEST.address);
    assert(PRUF_DAO_TEST.address !== "");
    DAO = PRUF_DAO_TEST;
  });

  it("Should build Roles", async () => {
    payableRoleB32 = await Helper.getStringHash("PAYABLE_ROLE");

    minterRoleB32 = await Helper.getStringHash("MINTER_ROLE");

    IDproviderRoleB32 = await Helper.getStringHash("ID_PROVIDER_ROLE");

    trustedAgentRoleB32 = await Helper.getStringHash("TRUSTED_AGENT_ROLE");

    assetTransferRoleB32 = await Helper.getStringHash("ASSET_TXFR_ROLE");

    IDminterRoleB32 = await Helper.getStringHash("ID_MINTER_ROLE");

    IDverifierRoleB32 = await Helper.getStringHash("ID_VERIFIER_ROLE");

    discardRoleB32 = await Helper.getStringHash("DISCARD_ROLE");

    DAOroleB32 = await Helper.getStringHash("DAO_ROLE");

    nodeAdminRoleB32 = await Helper.getStringHash("NODE_ADMIN_ROLE");

    nodeMinterRoleB32 = await Helper.getStringHash("NODE_MINTER_ROLE");

    contractAdminRoleB32 = await Helper.getStringHash("CONTRACT_ADMIN_ROLE");

    DAOcontrollerRoleB32 = await Helper.getStringHash("DAO_CONTROLLER_ROLE");

    DAOlayerRoleB32 = await Helper.getStringHash("DAO_LAYER_ROLE");

    DAOadminRoleB32 = await Helper.getStringHash("DAO_ADMIN_ROLE");

    pauserRoleB32 = await Helper.getStringHash("PAUSER_ROLE");

    stakeRoleB32 = await Helper.getStringHash("STAKE_ROLE");

    stakePayerRoleB32 = await Helper.getStringHash("STAKE_PAYER_ROLE");

    stakeAdminRoleB32 = await Helper.getStringHash("STAKE_ADMIN_ROLE");

    defaultAdminRoleB32 =
      "0x0000000000000000000000000000000000000000000000000000000000000000";
  });

  it("Should authorize account1 as DAOveto in DAO", () => {
    return DAO.grantRole(daoVetoRoleB32, account1, { from: account1 });
  });

  it("Should authorize DAO_A as DAOlayer in DAO_STOR", () => {
    console.log("Authorizing account1");
    return DAO_STOR.grantRole(DAOlayerRoleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should authorize DAO as DAOadmin in DAO_STOR", () => {
    return DAO_STOR.grantRole(DAOadminRoleB32, DAO.address, { from: account1 });
  });

  it("Should authorize DAO_A in STOR", () => {
    return STOR.grantRole(DAOroleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should authorize DAO_B in STOR", () => {
    return STOR.grantRole(DAOroleB32, DAO_B.address, {
      from: account1,
    });
  });

  it("Should add storage to DAO_A", () => {
    return DAO_A.setStorageContract(STOR.address, { from: account1 });
  });

  it("Should add storage to DAO_B", () => {
    return DAO_B.setStorageContract(STOR.address, { from: account1 });
  });

  it("Should add default contracts to storage", () => {
    console.log("Adding NODE_MGR to default contract list");
    return STOR.addDefaultContracts("0", "NODE_MGR", "1", { from: account1 })

      .then(() => {
        console.log("Adding NODE_TKN to default contract list");
        return STOR.addDefaultContracts("1", "NODE_TKN", "1", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding NODE_STOR to default contract list");
        return STOR.addDefaultContracts("2", "NODE_STOR", "1", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding A_TKN to default contract list");
        return STOR.addDefaultContracts("3", "A_TKN", "1", { from: account1 });
      })

      .then(() => {
        console.log("Adding APP_NC to default contract list");
        return STOR.addDefaultContracts("4", "APP_NC", "2", { from: account1 });
      });
  });

  it("Should add Storage to each contract", () => {
    console.log("Adding in NODE_MGR");
    return NODE_MGR.setStorageContract(STOR.address, {
      from: account1,
    })

      .then(() => {
        console.log("Adding in NODE_STOR");
        return NODE_STOR.setStorageContract(STOR.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding in A_TKN");
        return A_TKN.setStorageContract(STOR.address, { from: account1 });
      })

      .then(() => {
        console.log("Adding in APP_NC");
        return APP_NC.setStorageContract(STOR.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding in NODE_BLDR");
        return NODE_BLDR.setStorageContract(STOR.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding in DAO_A");
        return DAO_A.setStorageContract(STOR.address, { from: account1 });
      })

      .then(() => {
        console.log("Adding in DAO_B");
        return DAO_B.setStorageContract(STOR.address, { from: account1 });
      })

      .then(() => {
        console.log("Adding in DAO");
        return DAO.setStorageContract(STOR.address, { from: account1 });
      })

      .then(() => {
        console.log("Adding in DAO_STOR");
        return DAO_STOR.setStorageContract(STOR.address, { from: account1 });
      });
  });

  it("Should add contract addresses to storage", () => {
    console.log("Adding NODE_MGR to storage for use in Node 0");
    return STOR.authorizeContract("NODE_MGR", NODE_MGR.address, "0", "1", {
      from: account1,
    })

      .then(() => {
        console.log("Adding NODE_STOR to storage for use in Node 0");
        return STOR.authorizeContract(
          "NODE_STOR",
          NODE_STOR.address,
          "0",
          "1",
          {
            from: account1,
          }
        );
      })

      .then(() => {
        console.log("Adding NODE_TKN to storage for use in Node 0");
        return STOR.authorizeContract("NODE_TKN", NODE_TKN.address, "0", "1", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding A_TKN to storage for use in Node 0");
        return STOR.authorizeContract("A_TKN", A_TKN.address, "0", "1", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding APP_NC to storage for use in Node 0");
        return STOR.authorizeContract("APP_NC", APP_NC.address, "0", "2", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding UTIL_TKN to storage for use in Node 0");
        return STOR.authorizeContract("UTIL_TKN", UTIL_TKN.address, "0", "1", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding DECORATE to storage for use in Node 0");
        return STOR.authorizeContract("DAO_STOR", DAO_STOR.address, "0", "1", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding DECORATE to storage for use in Node 0");
        return STOR.authorizeContract("CLOCK", CLOCK.address, "0", "1", {
          from: account1,
        });
      });
  });

  it("Should resolve contract addresses", () => {
    console.log("Resolving in NODE_MGR");
    return NODE_MGR.resolveContractAddresses({ from: account1 })

      .then(() => {
        console.log("Resolving in NODE_STOR");
        return NODE_STOR.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in A_TKN");
        return A_TKN.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in APP_NC");
        return APP_NC.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in NODE_BLDR");
        return NODE_BLDR.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in DAO_A");
        return DAO_A.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in DAO_B");
        return DAO_B.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in DAO");
        return DAO.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in DAO_STOR");
        return DAO_STOR.resolveContractAddresses({ from: account1 });
      });
  });

  it("Should give DAO_A assetTransferRole for APP_NC", () => {
    return APP_NC.grantRole(assetTransferRoleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should give DAO_B assetTransferRole for APP_NC", () => {
    return APP_NC.grantRole(assetTransferRoleB32, DAO_B.address, {
      from: account1,
    });
  });

  it("Should authorize DAO_A with defaultAdminRole for A_TKN", () => {
    return A_TKN.grantRole(defaultAdminRoleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should authorize APP_NC with minterRole for A_TKN", () => {
    return A_TKN.grantRole(minterRoleB32, APP_NC.address, {
      from: account1,
    });
  });

  it("Should authorize DAO_A with DAOrole for A_TKN", () => {
    return A_TKN.grantRole(DAOroleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should authorize DAO_A with pauserRole for A_TKN", () => {
    return A_TKN.grantRole(pauserRoleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should authorize account1 with minterRole for A_TKN", () => {
    return A_TKN.grantRole(minterRoleB32, account1, {
      from: account1,
    });
  });

  it("Should authorize DAO_A with defaultAdminRole for UTIL_TKN", () => {
    return UTIL_TKN.grantRole(defaultAdminRoleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should authorize NODE_MGR with trustedAgentRole for UTIL_TKN", () => {
    console.log("Authorizing NODE_MGR");
    return UTIL_TKN.grantRole(trustedAgentRoleB32, NODE_MGR.address, {
      from: account1,
    });
  });

  it("Should authorize DAO_A with pauserRole for UTIL_TKN", () => {
    console.log("Authorizing DAO_A");
    return UTIL_TKN.grantRole(pauserRoleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should authorize all payable contracts for transactions", () => {
    console.log("Authorizing NODE_MGR");
    return UTIL_TKN.grantRole(payableRoleB32, NODE_MGR.address, {
      from: account1,
    })
    .then(() => {
      console.log("Authorizing APP_NC");
      return UTIL_TKN.grantRole(payableRoleB32, APP_NC.address, {
        from: account1,
      });
    });
  });

  it("Should authorize DAO_A with contractAdminRole for NODE_TKN", () => {
    console.log("Authorizing NODE_MGR");
    return NODE_TKN.grantRole(contractAdminRoleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should authorize DAO_A with pauserRole for NODE_TKN", () => {
    console.log("Authorizing NODE_MGR");
    return NODE_TKN.grantRole(pauserRoleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should authorize NODE_MGR with minterRole for NODE_TKN", () => {
    return NODE_TKN.grantRole(minterRoleB32, NODE_MGR.address, {
      from: account1,
    });
  });

  it("Should authorize DAO_A with defaultAdminRole for NODE_MGR", () => {
    return NODE_MGR.grantRole(defaultAdminRoleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should authorize account1 with IDverifierRole for NODE_MGR", () => {
    return NODE_MGR.grantRole(IDverifierRoleB32, account1, {
      from: account1,
    });
  });

  it("Should authorize NODE_BLDR with IDverifierRole for NODE_MGR", () => {
    return NODE_MGR.grantRole(IDverifierRoleB32, NODE_BLDR.address, {
      from: account1,
    });
  });

  it("Should authorize DAO_A with DAOrole for NODE_MGR", () => {
    return NODE_MGR.grantRole(DAOroleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should authorize DAO_A with pauserRole for NODE_MGR", () => {
    return NODE_MGR.grantRole(pauserRoleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should authorize DAO_A with defaultAdminRole for NODE_STOR", () => {
    return NODE_STOR.grantRole(defaultAdminRoleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should authorize DAO_A with DAOrole for NODE_STOR", () => {
    return NODE_STOR.grantRole(DAOroleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should authorize DAO_A with pauserRole for NODE_STOR", () => {
    return NODE_STOR.grantRole(pauserRoleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should authorize DAO_A with contractAdminRole for NODE_STOR", () => {
    return NODE_STOR.grantRole(contractAdminRoleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should authorize NODE_MGR with nodeAdminRole for NODE_STOR", () => {
    return NODE_STOR.grantRole(nodeAdminRoleB32, NODE_MGR.address, {
      from: account1,
    });
  });

  it("Should authorize account1 with nodeAdminRole for NODE_STOR", () => {
    return NODE_STOR.grantRole(nodeAdminRoleB32, account1, {
      from: account1,
    });
  });

  it("Should authorize account1 with DAOrole for NODE_STOR", () => {
    return STOR.grantRole(DAOroleB32, account1, {
      from: account1,
    });
  });

  it("Should authorize account1 with DAOrole for A_TKN", () => {
    console.log("Authorizing NODE_MGR");
    return A_TKN.grantRole(DAOroleB32, account1, {
      from: account1,
    });
  });

  it("Should set all permitted storage providers", () => {
    console.log("Authorizing UNCONFIGURED");
    return NODE_STOR.setStorageProviders("0", "1", { from: account1 })

      .then(() => {
        console.log("Authorizing Mutable");
        return NODE_STOR.setStorageProviders("1", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing ARWEAVE");
        return NODE_STOR.setStorageProviders("2", "1", { from: account1 });
      });
  });

  it("Should set all baseURI(s) for storage providers", () => {
    console.log("TEST0 == UNCONFIGURED");
    return A_TKN.setBaseURIforStorageType("0", "TEST0", { from: account1 })

      .then(() => {
        console.log("TEST1 == Mutable");
        return A_TKN.setBaseURIforStorageType("1", "TEST1", { from: account1 });
      })

      .then(() => {
        console.log("TEST2 == ARWEAVE");
        return A_TKN.setBaseURIforStorageType("2", "TEST2", { from: account1 });
      });
  });

  it("Should set all permitted management types", () => {
    console.log("Authorizing Unrestricted");
    return NODE_STOR.setManagementTypes("0", "1", { from: account1 })

      .then(() => {
        console.log("Authorizing Restricted");
        return NODE_STOR.setManagementTypes("1", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing Less Restricted");
        return NODE_STOR.setManagementTypes("2", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing Authorized");
        return NODE_STOR.setManagementTypes("3", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing Trusted");
        return NODE_STOR.setManagementTypes("4", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing Remotely Managed");
        return NODE_STOR.setManagementTypes("5", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing Unconfigured");
        return NODE_STOR.setManagementTypes("255", "1", { from: account1 });
      });
  });

  it("Should set all permitted custody types", () => {
    console.log("Authorizing NONE");
    return NODE_STOR.setCustodyTypes("0", "1", { from: account1 })

      .then(() => {
        console.log("Authorizing Custodial");
        return NODE_STOR.setCustodyTypes("1", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing Non-Custodial");
        return NODE_STOR.setCustodyTypes("2", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing ROOT");
        return NODE_STOR.setCustodyTypes("3", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing Verify-Non-Custodial");
        return NODE_STOR.setCustodyTypes("4", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing Wrapped or decorated ERC721");
        return NODE_STOR.setCustodyTypes("5", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing Free Custodial");
        return NODE_STOR.setCustodyTypes("11", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing Free Non-Custodial");
        return NODE_STOR.setCustodyTypes("12", "1", { from: account1 });
      });
  });

  it("Should mint root tokens", () => {
      console.log("Minting Art node")
      return NODE_MGR.createNode(
        "1",
        "Art",
        "1",
        "3",
        "0",
        "0",
        "9500",
        rgt000,
        rgt000,
        account1,
        { from: account1 }
      ).then(() => {
        console.log("Minting Apparel node")
        return NODE_MGR.createNode(
            "2",
            "Apparel",
            "2",
            "3",
            "0",
            "0",
            "9500",
            rgt000,
            rgt000,
            account1,
        );
      }).then(() => {
        console.log("Minting Ticketing node")
        return NODE_MGR.createNode(
            "3",
            "Ticketing",
            "3",
            "3",
            "0",
            "0",
            "9500",
            rgt000,
            rgt000,
            account1,
        );
      }).then(() => {
        console.log("Minting Consumables node")
        return NODE_MGR.createNode(
            "4",
            "Consumables",
            "4",
            "3",
            "0",
            "0",
            "9500",
            rgt000,
            rgt000,
            account1,
        );
      }).then(() => {
        console.log("Minting Transportation node")
        return NODE_MGR.createNode(
            "5",
            "Transportation",
            "5",
            "3",
            "0",
            "0",
            "9500",
            rgt000,
            rgt000,
            account1,
        );
      }).then(() => {
        console.log("Minting Industrial node")
        return NODE_MGR.createNode(
            "6",
            "Industrial",
            "6",
            "3",
            "0",
            "0",
            "9500",
            rgt000,
            rgt000,
            account1,
        );
      }).then(() => {
        console.log("Minting Miscellaneous node")
        return NODE_MGR.createNode(
            "7",
            "Miscellaneous",
            "7",
            "3",
            "0",
            "0",
            "9500",
            rgt000,
            rgt000,
            account1,
        );
      })
  });

  it("Should set costs in Art", () => {
    return NODE_MGR.setOperationCosts("1", "1", "10000000000000000", account1, {
      from: account1,
    })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "1",
          "2",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "1",
          "3",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "1",
          "4",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "1",
          "5",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "1",
          "6",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "1",
          "7",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "1",
          "8",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })
  });

  it("Should set costs in Apparel", () => {
    return NODE_MGR.setOperationCosts("2", "1", "10000000000000000", account1, {
      from: account1,
    })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "2",
          "2",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "2",
          "3",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "2",
          "4",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "2",
          "5",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "2",
          "6",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "2",
          "7",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "2",
          "8",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })
  });

  it("Should set costs in Ticketing", () => {
    return NODE_MGR.setOperationCosts("3", "1", "10000000000000000", account1, {
      from: account1,
    })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "3",
          "2",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "3",
          "3",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "3",
          "4",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "3",
          "5",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "3",
          "6",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "3",
          "7",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "3",
          "8",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })
  });

  it("Should set costs in Consumables", () => {
    return NODE_MGR.setOperationCosts("4", "1", "10000000000000000", account1, {
      from: account1,
    })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "4",
          "2",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "4",
          "3",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "4",
          "4",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "4",
          "5",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "4",
          "6",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "4",
          "7",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "4",
          "8",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })
  });

  it("Should set costs in Transportation", () => {
    return NODE_MGR.setOperationCosts("5", "1", "10000000000000000", account1, {
      from: account1,
    })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "5",
          "2",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "5",
          "3",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "5",
          "4",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "5",
          "5",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "5",
          "6",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "5",
          "7",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "5",
          "8",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })
  });

  it("Should set costs in Industrial", () => {
    return NODE_MGR.setOperationCosts("6", "1", "10000000000000000", account1, {
      from: account1,
    })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "6",
          "2",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "6",
          "3",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "6",
          "4",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "6",
          "5",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "6",
          "6",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "6",
          "7",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "6",
          "8",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })
  });

  it("Should set costs in Miscellaneous", () => {
    return NODE_MGR.setOperationCosts("7", "1", "10000000000000000", account1, {
      from: account1,
    })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "7",
          "2",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "7",
          "3",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "7",
          "4",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "7",
          "5",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "7",
          "6",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "7",
          "7",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "7",
          "8",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })
  });
});
