package com.depi206.todolist;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
public class TodoController {

    private final TodoConfig todoConfig;

    public TodoController(TodoConfig todoConfig) {
        this.todoConfig = todoConfig;
    }

    @GetMapping("/todos")
    public List<String> getTodos() {
        return todoConfig.getTodos();
    }
}
