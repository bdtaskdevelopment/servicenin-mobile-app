package com.sslwireless.sslcommerz;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.sslwireless.sslcommerz.helper.InitializationHelper;
import com.sslwireless.sslcommerz.model.SDKDataModel;
import com.sslwireless.sslcommerz.model.Initializer;
import com.sslwireless.sslcommerz.util.SSLCLog;


import com.sslwireless.sslcommerzlibrary.model.initializer.SSLCAdditionalInitializer;
import com.sslwireless.sslcommerzlibrary.model.initializer.SSLCCustomerInfoInitializer;
import com.sslwireless.sslcommerzlibrary.model.initializer.SSLCProductInitializer;
import com.sslwireless.sslcommerzlibrary.model.initializer.SSLCShipmentInfoInitializer;
import com.sslwireless.sslcommerzlibrary.model.initializer.SSLCommerzInitialization;
import com.sslwireless.sslcommerzlibrary.model.response.SSLCTransactionInfoModel;
import com.sslwireless.sslcommerzlibrary.model.util.SSLCCurrencyType;
import com.sslwireless.sslcommerzlibrary.model.util.SSLCSdkType;
import com.sslwireless.sslcommerzlibrary.view.singleton.IntegrateSSLCommerz;
import com.sslwireless.sslcommerzlibrary.viewmodel.listener.SSLCTransactionResponseListener;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * SslcommerzPlugin
 */
public class FlutterSslcommerzPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private MethodChannel channel;
    private Context context;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        SSLCLog.init(flutterPluginBinding.getApplicationContext());
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_sslcommerz");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
        if (call.method.equals("initiateSSLCommerz")) {
            SSLCLog.d("onMethodCall: " +  call.arguments.toString());
            SDKDataModel sdkDataModel = new Gson().fromJson(call.arguments.toString(), SDKDataModel.class);
            if (sdkDataModel != null && sdkDataModel.getInitializer() != null) {
            } else {
                SSLCLog.e("Failed to parse SDKDataModel or Initializer is null");
            }

            IntegrateSSLCommerz integrateSSLCommerz = IntegrateSSLCommerz.getInstance(context)
                    .addSSLCommerzInitialization(InitializationHelper.sslCommerzInitialization(sdkDataModel));

            if (sdkDataModel.getCustomerInfoInitializer() != null)
                integrateSSLCommerz.addCustomerInfoInitializer(InitializationHelper.initiateCustomerInfo(sdkDataModel));

            if (sdkDataModel.getSslcemiTransactionInitializer() != null)
                integrateSSLCommerz
                        .addEMITransactionInitializer(InitializationHelper.initiateEmiTransaction(sdkDataModel));

            if (sdkDataModel.getSslcShipmentInfoInitializer() != null)
                integrateSSLCommerz.addShipmentInfoInitializer(InitializationHelper.initiateShipmentInfo(sdkDataModel));
            if (sdkDataModel.getSslcProductInitializer() != null)
                integrateSSLCommerz
                        .addProductInitializer(InitializationHelper.initiateProductInitializer(sdkDataModel));
            if (sdkDataModel.getSslcAdditionalInitializer() != null)
                integrateSSLCommerz
                        .addAdditionalInitializer(InitializationHelper.getAdditionalInitializer(sdkDataModel));

            integrateSSLCommerz.buildApiCall(new SSLCTransactionResponseListener() {
                @Override
                public void transactionSuccess(SSLCTransactionInfoModel sslcTransactionInfoModel) {
                    result.success(new Gson().toJson(sslcTransactionInfoModel));
                }

                @Override
                public void transactionFail(String s) {
                    SSLCTransactionInfoModel sslcTransactionInfoModel = new SSLCTransactionInfoModel();
                    sslcTransactionInfoModel.setStatus("FAILED");
                    result.success(new Gson().toJson(sslcTransactionInfoModel));
                    // Toast.makeText(context, s, Toast.LENGTH_SHORT).show();
                }

                @Override
                public void closed(String s) {
                    SSLCTransactionInfoModel sslcTransactionInfoModel = new SSLCTransactionInfoModel();
                    sslcTransactionInfoModel.setStatus("closed");
                    result.success(new Gson().toJson(sslcTransactionInfoModel));

                }
            });
        }

        else {
            result.notImplemented();
        }
    }

    private void showErrorAlert(String title, String message) {
        new AlertDialog.Builder(context).setTitle(title).setMessage(message)
                .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                    }
                }).show();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        context = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    }

    @Override
    public void onDetachedFromActivity() {

    }
}