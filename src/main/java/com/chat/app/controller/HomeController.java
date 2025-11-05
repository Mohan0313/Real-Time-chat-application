package com.chat.app.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    // Redirect root to the chat page
    @GetMapping("/")
    public String home() {
        return "redirect:/chat";
    }
}
