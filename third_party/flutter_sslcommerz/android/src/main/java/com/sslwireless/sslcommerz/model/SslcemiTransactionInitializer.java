package com.sslwireless.sslcommerz.model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class SslcemiTransactionInitializer {

    @SerializedName("emi_options")
    @Expose
    private Integer emiOptions;
    @SerializedName("emi_max_list_options")
    @Expose
    private Integer emiMaxListOptions;
    @SerializedName("emi_selected_inst")
    @Expose
    private Integer emiSelectedInst;

 public SslcemiTransactionInitializer() {
    this.emiOptions = 0;
    this.emiMaxListOptions = 0;
    this.emiSelectedInst = 0;
}
    SslcemiTransactionInitializer(Integer emiOptions, Integer emiMaxListOptions, Integer emiSelectedInst) {
        this.emiOptions = emiOptions;
        this.emiMaxListOptions = emiMaxListOptions;
        this.emiSelectedInst = emiSelectedInst;
    }

    public Integer getEmiOptions() {
        return emiOptions;
    }

    public void setEmiOptions(Integer emiOptions) {
        this.emiOptions = emiOptions;
    }

    public Integer getEmiMaxListOptions() {
        return emiMaxListOptions;
    }

    public void setEmiMaxListOptions(Integer emiMaxListOptions) {
        this.emiMaxListOptions = emiMaxListOptions;
    }

    public Integer getEmiSelectedInst() {
        return emiSelectedInst;
    }

    public void setEmiSelectedInst(Integer emiSelectedInst) {
        this.emiSelectedInst = emiSelectedInst;
    }

}
