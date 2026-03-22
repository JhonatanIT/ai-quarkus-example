package org.acme;

import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

@Provider
public class GlobalExceptionMapper implements ExceptionMapper<Throwable> {

    @Override
    public Response toResponse(Throwable t) {
        return Response.status(500)
                .entity("CRITICAL_FAILURE: " + t.getClass().getName() + " \nMessage: " + t.getMessage())
                .build();
    }
}