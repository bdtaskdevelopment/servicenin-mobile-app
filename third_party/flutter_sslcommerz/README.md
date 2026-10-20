# Welcome to SSLCommerz Flutter Plugin!

This is the official **SSLCommerz** flutter plugin for Flutter application integration. For, now it only supports **Android and iOS only**.

## 🆕 Android 16KB Page Support
This version includes support for **16KB page sizes** on Android devices, ensuring compatibility with modern Android devices and improved performance.

## Deployment Target

> For iOS : **Deployment Target : 13.0**
> For Android : **minSdkVersion 21** with **16KB Page Support**


# For a payment call please use the below template:


## Initialization
First of all, initialize the sslcommerz SDK with some mandatory fields.

> Here, fill the **ipn_field**, if you have a valid one, or it will fail
> the transaction.

    Sslcommerz sslcommerz = Sslcommerz(
        initializer: SSLCommerzInitialization(
     //   ipn_url: "www.ipnurl.com",
      multi_card_name: "visa,master,bkash",
      currency: SSLCurrencyType.BDT,
      product_category: "Food",
      sdkType: SSLCSdkType.TESTBOX,
      store_id: "your_store_id",
      store_passwd: "your_store_password",
      total_amount: "payment_amount",
      tran_id: "custom_transaction_id"));


## To customized the payment, initiate the below vertices as required for your business
**Add EMI option with the below code snippet:**

    sslcommerz
        .addEMITransactionInitializer(
            sslcemiTransactionInitializer: SSLCEMITransactionInitializer(
                emi_options: 1));

**Add SHIPMENT information with below code snipptet:**

    sslcommerz.addShipmentInfoInitializer(
        sslcShipmentInfoInitializer: SSLCShipmentInfoInitializer(
            shipmentMethod: "yes",
      numOfItems: 5,
      shipmentDetails: ShipmentDetails(
                shipAddress1: "Ship address 1",
      shipCity: "Faridpur",
      shipCountry: "Bangladesh",
      shipName: "Ship name 1",
      shipPostCode: "7860")));

**Add CUSTOMER information with the below shippet:**

    sslcommerz.addCustomerInfoInitializer(
            customerInfoInitializer: SSLCCustomerInfoInitializer(
                customerState: "Chattogram",
                customerName: "Abu Sayed Chowdhury",
                customerEmail: "sayem227@gmail.com",
                customerAddress1: "Chattogram",
                customerCity: "Chattogram",
                customerPostCode: "200",
                customerCountry: "Bangladesh",
                customerPhone: formData['phone']));

> Add only one product from the below. Adding multiple type of product
> may create conflicts.

***To add general product please use the below snippet:***

    sslcommerz.addProductInitializer(
        sslcProductInitializer:
      SSLCProductInitializer(
                productName: "Water Filter",
      productCategory: "Widgets",
      general: General(
                    general: "General Purpose",
      productProfile: "Product Profile"));


***To add non-physical goods as your product use the below snippet:***

        sslcommerz.addProductInitializer(
            sslcProductInitializer:
	          SSLCProductInitializer.WithNonPhysicalGoodsProfile(
			         productName:  "productName",
				     productCategory:"productCategory",
				     nonPhysicalGoods:
				       NonPhysicalGoods(productProfile: "Product profile",
					     nonPhysicalGoods:"non physical good"
           )));

***To add travel vertices as your product use the below snippet:***

            sslcommerz.addProductInitializer(
                sslcProductInitializer:
                SSLCProductInitializer.WithTravelVerticalProfile(
			       productName:"productName",
			       productCategory:"productCategory",
			       travelVertical:TravelVertical(
			            productProfile: "productProfile",
					    hotelName: "hotelName",
					    lengthOfStay: "lengthOfStay",
				        checkInTime: "checkInTime",
				        hotelCity: "hotelCity"
				)));

***To add travel vertices as your product use the below snippet:***

            sslcommerz.addProductInitializer(
                sslcProductInitializer:
                SSLCProductInitializer.WithPhysicalGoodsProfile(
				    productName: "productName",
				    productCategory: "productCategory",
				    physicalGoods: PhysicalGoods(
				        productProfile: "Product profile",
						physicalGoods: "non physical good"
			)));

***To add TELECOM as your product use the below snippet:***

            sslcommerz.addProductInitializer(
                sslcProductInitializer:
                SSLCProductInitializer.WithTelecomVerticalProfile(
				    productName: "productName",
				    productCategory: "productCategory",
					telecomVertical: TelecomVertical(
				        productProfile: "productProfile",
					    productType: "productType",
					    topUpNumber: "topUpNumber",
						countryTopUp: "countryTopUp"
				)));


## You can add optional parametes with the payment sdk by adding the below snippet:

    sslcommerz.addAdditionalInitializer(
        sslcAdditionalInitializer: SSLCAdditionalInitializer(
            valueA: "value a ",
      valueB: "value b",
      valueC: "value c",
      valueD: "value d"));

And then finally **`sslcommerz.payNow();`** will initiate the SDK to complete the payment process.
