package com.example.app.item;

import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/items")
public class ItemController {
    private final ItemRepository items;
    
    public ItemController(ItemRepository items) {
        this.items = items;
    }
    
    @GetMapping
    public List<Item> myItems(Authentication auth) {
        return items.findByOwnerEmailOrderByCreatedAtDesc(auth.getName());
    }
    
    public record ItemCreate(String name, String description) {}
    
    @PostMapping
    public Item create(@Valid @RequestBody ItemCreate in, Authentication auth) {
        var it = new Item();
        it.setName(in.name());
        it.setDescription(in.description());
        it.setOwnerEmail(auth.getName());
        return items.save(it);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable UUID id, Authentication auth) {
        var it = items.findById(id).orElse(null);
        
        if (it == null || !it.getOwnerEmail().equals(auth.getName())) {
            return ResponseEntity.status(404).build();
        }
        
        items.delete(it);
        return ResponseEntity.noContent().build();
    }
}
