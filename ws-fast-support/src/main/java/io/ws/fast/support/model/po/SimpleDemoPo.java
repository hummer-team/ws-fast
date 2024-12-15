package io.ws.fast.support.model.po;

import lombok.Data;

/**
 * base po
 *
 * @Author edz
 * @Copyright 20219
 */
@Data
public class SimpleDemoPo extends BasePo {
    private Integer id;
    private String thirdPartyDeliveryId;
    private String deliveryCompanyCode;
    private String batchId;
    private String buyerId;
    private Integer deliveryType;
    private String deliveryTypeDescribe;
    private Integer callApiTimeoutMillisecond;
    private String deliveryInfoChannel;
    private String proxyExpressCompanyCode;
}