package com.sslwireless.sslcommerz.model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class SslcProductInitializer {

    @SerializedName("productName")
    @Expose
    private String productName;
    
    @SerializedName("productCategory")
    @Expose
    private String productCategory;
    
    @SerializedName("cart")
    @Expose
    private Object cart;
    
    @SerializedName("productAmount")
    @Expose
    private Object productAmount;
    
    @SerializedName("vat")
    @Expose
    private Object vat;
    
    @SerializedName("discountAmount")
    @Expose
    private Object discountAmount;
    
    @SerializedName("convenienceFee")
    @Expose
    private Object convenienceFee;
    
    @SerializedName("airlinesTicket")
    @Expose
    private AirlinesTicket airlinesTicket;
    
    @SerializedName("general")
    @Expose
    private General general;
    
    @SerializedName("physicalGoods")
    @Expose
    private PhysicalGoods physicalGoods;
    
    @SerializedName("nonPhysicalGoods")
    @Expose
    private NonPhysicalGoods nonPhysicalGoods;
    
    @SerializedName("telecomVertical")
    @Expose
    private TelecomVertical telecomVertical;
    
    @SerializedName("travelVertical")
    @Expose
    private TravelVertical travelVertical;

    // Default constructor for SslcProductInitializer
    public SslcProductInitializer() {
        this.productName = "";
        this.productCategory = "";
        this.cart = null;
        this.productAmount = null;
        this.vat = null;
        this.discountAmount = null;
        this.convenienceFee = null;
        this.airlinesTicket = new AirlinesTicket();
        this.general = new General();
        this.physicalGoods = new PhysicalGoods();
        this.nonPhysicalGoods = new NonPhysicalGoods();
        this.telecomVertical = new TelecomVertical();
        this.travelVertical = new TravelVertical();
    }

    // Getters and Setters

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getProductCategory() {
        return productCategory;
    }

    public void setProductCategory(String productCategory) {
        this.productCategory = productCategory;
    }

    public Object getCart() {
        return cart;
    }

    public void setCart(Object cart) {
        this.cart = cart;
    }

    public Object getProductAmount() {
        return productAmount;
    }

    public void setProductAmount(Object productAmount) {
        this.productAmount = productAmount;
    }

    public Object getVat() {
        return vat;
    }

    public void setVat(Object vat) {
        this.vat = vat;
    }

    public Object getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(Object discountAmount) {
        this.discountAmount = discountAmount;
    }

    public Object getConvenienceFee() {
        return convenienceFee;
    }

    public void setConvenienceFee(Object convenienceFee) {
        this.convenienceFee = convenienceFee;
    }

    public AirlinesTicket getAirlinesTicket() {
        return airlinesTicket;
    }

    public void setAirlinesTicket(AirlinesTicket airlinesTicket) {
        this.airlinesTicket = airlinesTicket;
    }

    public General getGeneral() {
        return general;
    }

    public void setGeneral(General general) {
        this.general = general;
    }

    public PhysicalGoods getPhysicalGoods() {
        return physicalGoods;
    }

    public void setPhysicalGoods(PhysicalGoods physicalGoods) {
        this.physicalGoods = physicalGoods;
    }

    public NonPhysicalGoods getNonPhysicalGoods() {
        return nonPhysicalGoods;
    }

    public void setNonPhysicalGoods(NonPhysicalGoods nonPhysicalGoods) {
        this.nonPhysicalGoods = nonPhysicalGoods;
    }

    public TelecomVertical getTelecomVertical() {
        return telecomVertical;
    }

    public void setTelecomVertical(TelecomVertical telecomVertical) {
        this.telecomVertical = telecomVertical;
    }

    public TravelVertical getTravelVertical() {
        return travelVertical;
    }

    public void setTravelVertical(TravelVertical travelVertical) {
        this.travelVertical = travelVertical;
    }

    // Nested classes with default constructors

    public static class AirlinesTicket {
        @SerializedName("productProfile")
        @Expose
        String productProfile;
        
        @SerializedName("hoursTillDeparture")
        @Expose
        String hoursTillDeparture;
        
        @SerializedName("flightType")
        @Expose
        String flightType;
        
        @SerializedName("pnr")
        @Expose
        String pnr;
        
        @SerializedName("journeyFromTo")
        @Expose
        String journeyFromTo;
        
        @SerializedName("thirdPartyBooking")
        @Expose
        String thirdPartyBooking;

        // Default constructor for AirlinesTicket
        public AirlinesTicket() {
            this.productProfile = "";
            this.hoursTillDeparture = "";
            this.flightType = "";
            this.pnr = "";
            this.journeyFromTo = "";
            this.thirdPartyBooking = "";
        }

        // Getters and Setters
        public String getProductProfile() {
            return productProfile;
        }

        public void setProductProfile(String productProfile) {
            this.productProfile = productProfile;
        }

        public String getHoursTillDeparture() {
            return hoursTillDeparture;
        }

        public void setHoursTillDeparture(String hoursTillDeparture) {
            this.hoursTillDeparture = hoursTillDeparture;
        }

        public String getFlightType() {
            return flightType;
        }

        public void setFlightType(String flightType) {
            this.flightType = flightType;
        }

        public String getPnr() {
            return pnr;
        }

        public void setPnr(String pnr) {
            this.pnr = pnr;
        }

        public String getJourneyFromTo() {
            return journeyFromTo;
        }

        public void setJourneyFromTo(String journeyFromTo) {
            this.journeyFromTo = journeyFromTo;
        }

        public String getThirdPartyBooking() {
            return thirdPartyBooking;
        }

        public void setThirdPartyBooking(String thirdPartyBooking) {
            this.thirdPartyBooking = thirdPartyBooking;
        }
    }

    public static class General {
        @SerializedName("general")
        @Expose
        private String general;
        
        @SerializedName("productProfile")
        @Expose
        private String productProfile;

        // Default constructor for General
        public General() {
            this.general = "";
            this.productProfile = "";
        }

        // Getters and Setters
        public String getGeneral() {
            return general;
        }

        public void setGeneral(String general) {
            this.general = general;
        }

        public String getProductProfile() {
            return productProfile;
        }

        public void setProductProfile(String productProfile) {
            this.productProfile = productProfile;
        }
    }

    public static class PhysicalGoods {
        @SerializedName("physicalGoods")
        @Expose
        private String physicalGoods;
        
        @SerializedName("productProfile")
        @Expose
        private String productProfile;

        // Default constructor for PhysicalGoods
        public PhysicalGoods() {
            this.physicalGoods = "";
            this.productProfile = "";
        }

        // Getters and Setters
        public String getPhysicalGoods() {
            return physicalGoods;
        }

        public void setPhysicalGoods(String physicalGoods) {
            this.physicalGoods = physicalGoods;
        }

        public String getProductProfile() {
            return productProfile;
        }

        public void setProductProfile(String productProfile) {
            this.productProfile = productProfile;
        }
    }

    public static class TravelVertical {
        @SerializedName("productProfile")
        @Expose
        private String productProfile;
        
        @SerializedName("hotelName")
        @Expose
        private String hotelName;
        
        @SerializedName("lengthOfStay")
        @Expose
        private String lengthOfStay;
        
        @SerializedName("checkInTime")
        @Expose
        private String checkInTime;
        
        @SerializedName("hotelCity")
        @Expose
        private String hotelCity;

        // Default constructor for TravelVertical
        public TravelVertical() {
            this.productProfile = "";
            this.hotelName = "";
            this.lengthOfStay = "";
            this.checkInTime = "";
            this.hotelCity = "";
        }

        // Getters and Setters
        public String getProductProfile() {
            return productProfile;
        }

        public void setProductProfile(String productProfile) {
            this.productProfile = productProfile;
        }

        public String getHotelName() {
            return hotelName;
        }

        public void setHotelName(String hotelName) {
            this.hotelName = hotelName;
        }

        public String getLengthOfStay() {
            return lengthOfStay;
        }

        public void setLengthOfStay(String lengthOfStay) {
            this.lengthOfStay = lengthOfStay;
        }

        public String getCheckInTime() {
            return checkInTime;
        }

        public void setCheckInTime(String checkInTime) {
            this.checkInTime = checkInTime;
        }

        public String getHotelCity() {
            return hotelCity;
        }

        public void setHotelCity(String hotelCity) {
            this.hotelCity = hotelCity;
        }
    }

    public static class TelecomVertical {
        @SerializedName("productProfile")
        @Expose
        private String productProfile;
        
        @SerializedName("productType")
        @Expose
        private String productType;
        
        @SerializedName("topUpNumber")
        @Expose
        private String topUpNumber;
        
        @SerializedName("countryTopUp")
        @Expose
        private String countryTopUp;

        // Default constructor for TelecomVertical
        public TelecomVertical() {
            this.productProfile = "";
            this.productType = "";
            this.topUpNumber = "";
            this.countryTopUp = "";
        }

        // Getters and Setters
        public String getProductProfile() {
            return productProfile;
        }

        public void setProductProfile(String productProfile) {
            this.productProfile = productProfile;
        }

        public String getProductType() {
            return productType;
        }

        public void setProductType(String productType) {
            this.productType = productType;
        }

        public String getTopUpNumber() {
            return topUpNumber;
        }

        public void setTopUpNumber(String topUpNumber) {
            this.topUpNumber = topUpNumber;
        }

        public String getCountryTopUp() {
            return countryTopUp;
        }

        public void setCountryTopUp(String countryTopUp) {
            this.countryTopUp = countryTopUp;
        }
    }

    public static class NonPhysicalGoods {
        @SerializedName("nonPhysicalGoods")
        @Expose
        private String nonPhysicalGoods;
        
        @SerializedName("productProfile")
        @Expose
        private String productProfile;

        // Default constructor for NonPhysicalGoods
        public NonPhysicalGoods() {
            this.nonPhysicalGoods = "";
            this.productProfile = "";
        }

        // Getters and Setters
        public String getProductProfile() {
            return productProfile;
        }

        public void setProductProfile(String productProfile) {
            this.productProfile = productProfile;
        }

        public String getNonPhysicalGoods() {
            return nonPhysicalGoods;
        }

        public void setNonPhysicalGoods(String nonPhysicalGoods) {
            this.nonPhysicalGoods = nonPhysicalGoods;
        }
    }
}
