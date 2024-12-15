package io.ws.fast.api.controller;

import com.hummer.rest.model.ResourceResponse;
import com.hummer.rest.utils.ParameterAssertUtil;
import io.ws.fast.facade.SimpleDemoFacade;
import io.ws.fast.facade.dto.request.SimpleDemoSaveReqDto;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.Errors;
import org.hibernate.validator.constraints.Length;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;

import com.hummer.common.security.Md5;

/**
 * Delivery Line enter
 */
@RestController
@RequestMapping(value = "/v1")
@Api(value = "this simple controller demo for learning")
@Validated
public class SimpleController {
    @Autowired
    private SimpleDemoFacade simpleDemoFacade;

    @PostMapping(value = "/simple/save")
    @ApiOperation(value = "this is save batch info to db demo")
    public ResourceResponse save(@RequestBody @Valid SimpleDemoSaveReqDto reqDto
            , Errors errors) {
        ParameterAssertUtil.assertRequestFirstValidated(errors);
        simpleDemoFacade.save(reqDto);
        return ResourceResponse.ok();
    }

    @GetMapping(value = "/simple/query-single")
    @ApiOperation(value = "this is query demo")
    public ResourceResponse save(@RequestParam("id")
                                 @NotEmpty(message = "id can't null")
                                 @Length(max = 100, message = "max length 100 char.") String id) {
        String ids = Md5.encryptMd5(id);
        return ResourceResponse.ok(simpleDemoFacade.querySingleById(ids));
    }
}