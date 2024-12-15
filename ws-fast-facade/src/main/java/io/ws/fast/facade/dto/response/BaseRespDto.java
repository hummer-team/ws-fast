package io.ws.fast.facade.dto.response;

import lombok.Data;

import java.util.Date;

/**
 * BaseRespDto
 *
 * @Author edz
 * @Copyright 20219
 */
@Data
public class BaseRespDto {
    private Date lastModifiedDateTime;
    private String createdUserId;
    private Date createdDateTime;
    private String lastModifiedUserId;
    private Boolean isDeleted;
}
