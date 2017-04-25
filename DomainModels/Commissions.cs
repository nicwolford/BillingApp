using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.Mvc;
using ScreeningONE.Models;
using ScreeningONE.Objects;

namespace ScreeningONE.DomainModels
{
    public class Commissions
    {

        public static List<S1_Commissions_PackageCommissionsResult> PackageCommissions()
        {
            using (CommissionsDataContext dc = new CommissionsDataContext())
            {
                return dc.S1_Commissions_PackageCommissions().ToList();
            }
        }

        public static List<S1_Commissions_CreatePackageCommissionsResult> CreatePackageCommissions(string ClientID, string ClientName, string PackageName,
                                                                                                   string PackageProducts, decimal PackageCommissionRate, int? BillingClientID)
        {            
            using (CommissionsDataContext dc = new CommissionsDataContext())
            {
                return dc.S1_Commissions_CreatePackageCommissions(ClientID, ClientName, PackageName,
                                                                  PackageProducts, PackageCommissionRate, BillingClientID).ToList();
            }
        }

        public static List<S1_Commissions_CreatePackageCommissionsResult> CreatePackageCommissions(string ClientName, string PackageName,
                                                                                                   decimal PackageCommissionRate)
        {
            return CreatePackageCommissions(null, ClientName, PackageName,
                                            null, PackageCommissionRate, null);
        }

        public static List<S1_Commissions_UpdatePackageCommissionsResult> UpdatePackageCommissions(int PackageCommissionID, string ClientID, string ClientName, 
                                                                                                   string PackageName, string PackageProducts, decimal PackageCommissionRate, 
                                                                                                   int? BillingClientID)
        {
            using (CommissionsDataContext dc = new CommissionsDataContext())
            {
                return dc.S1_Commissions_UpdatePackageCommissions(PackageCommissionID, ClientID, ClientName, 
                                                                  PackageName, PackageProducts, PackageCommissionRate, 
                                                                  BillingClientID).ToList();
            }
        }

        public static List<S1_Commissions_UpdatePackageCommissionsResult> UpdatePackageCommissions(int PackageCommissionID, string ClientName, string PackageName, 
                                                                                                   decimal PackageCommissionRate)
        {
            using (CommissionsDataContext dc = new CommissionsDataContext())
            {
                return dc.S1_Commissions_UpdatePackageCommissions(PackageCommissionID, null, ClientName, 
                                                                  PackageName, null, PackageCommissionRate, 
                                                                  null).ToList();
            }
        }

        public static List<S1_Commissions_RemovePackageCommissionsResult> RemovePackageCommissions(int PackageCommissionID)
        {
            using (CommissionsDataContext dc = new CommissionsDataContext())
            {
                return dc.S1_Commissions_RemovePackageCommissions(PackageCommissionID).ToList();
            }
        }

        public static List<S1_Commissions_ClientsSearchByClientNameResult> ClientsSearchByClientName(string clientName)
        {
            using (CommissionsDataContext dc = new CommissionsDataContext())
            {
                return dc.S1_Commissions_ClientsSearchByClientName(clientName).ToList();
            }
        }

    }
}