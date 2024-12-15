package io.ws.fast.service.domain.event.handle;

import  io.ws.fast.service.domain.event.BaseEvent;

import jakarta.validation.constraints.NotNull;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class EventHandle {
    @EventListener
    public void handle(@NotNull BaseEvent event) {
        log.debug("handle vent {}", event);
    }
}