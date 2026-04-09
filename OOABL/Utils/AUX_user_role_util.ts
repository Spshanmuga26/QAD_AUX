//test user role
      const usrRoleList = this.ViewController.SessionInfo.CurrentUserRolesIDs;
      console.log(usrRoleList);
      const hasRole = usrRoleList.some(
        (role: any) => role === 'ChiefFinancialOffcr'
      );
      if(!hasRole){
        this.ViewController.getViewField("xxSalesOrderHeadersemail3AutoField").IsDisabled = true;
      }
    }