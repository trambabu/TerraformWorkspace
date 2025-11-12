package com.imlokal;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
  @GetMapping("/actuator/health")
  public String health() { return "UP"; }
  @GetMapping("/")
  public String home() { return "Hello from imlokal backend!"; }
}
