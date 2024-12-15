package io.ws.fast.support.model.po;

import lombok.Data;

import java.util.Date;

/**
 * base po
 *
 * @Author edz
 * @Copyright 20219
 */
@Data
public class BasePo {
    private Date lastModifiedDateTime;
    private String createdUserId;
    private Date createdDateTime;
    private String lastModifiedUserId;
    private Boolean isDeleted;
}
