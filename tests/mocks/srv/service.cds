using API_BUSINESS_PARTNER as BUPA_API from './external/API_BUSINESS_PARTNER';
namespace service.businessPartnerValidationMocks;
 
 
service SalesServiceMocks {

  @readonly entity BusinessPartner as projection on BUPA_API.A_BusinessPartner{
     key BusinessPartner as businessPartnerId,
      BusinessPartnerFullName as businessPartnerName
  };

}


