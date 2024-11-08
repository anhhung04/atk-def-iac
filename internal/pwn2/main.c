#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "./lib/sqlite3.h"

#define MAX_USERNAME_LENGTH 50
#define MAX_PASSWORD_LENGTH 50
#define MAX_CONTENT_LENGTH 1280
#define MAX_SQL_LENGTH 1024
#define MAX_NOTES 10

#define DB_PATH "/tmp/notes.db"

typedef struct
{
    char username[MAX_USERNAME_LENGTH];
    int logged_in;
    int is_admin;
} User;

typedef struct
{
    int id;
    char *content;
} Note;

User current_user = {"", 0, 0};
Note *notes[MAX_NOTES] = {NULL};

sqlite3 *db;

void vulnerable_memcpy(char *dest, const char *src, size_t n)
{
    while (n--)
    {
        *dest++ = *src++;
    }
}

void add_note()
{
    if (!current_user.logged_in)
    {
        printf("Please log in first\n");
        return;
    }

    char content[MAX_CONTENT_LENGTH];
    int note_id = -1;

    for (int i = 0; i < MAX_NOTES; i++)
    {
        if (notes[i] == NULL)
        {
            note_id = i;
            break;
        }
    }

    if (note_id == -1)
    {
        printf("Maximum number of notes reached\n");
        return;
    }

    printf("Enter your note content: ");
    getchar();
    fgets(content, sizeof(content), stdin);
    content[strcspn(content, "\n")] = 0;

    notes[note_id] = (Note *)malloc(sizeof(Note));
    notes[note_id]->id = note_id;
    notes[note_id]->content = (char *)malloc(strlen(content) + 1);
    vulnerable_memcpy(notes[note_id]->content, content, strlen(content) + 1);

    printf("Note added successfully with ID: %d\n", note_id);
}

void view_notes()
{
    if (!current_user.logged_in)
    {
        printf("Please log in first\n");
        return;
    }

    printf("Your notes:\n");
    for (int i = 0; i < MAX_NOTES; i++)
    {
        if (notes[i] != NULL)
        {
            printf("Note ID: %d\n", notes[i]->id);
            printf("Content: %s\n", notes[i]->content);
            printf("--------------------\n");
        }
    }
}

void delete_note()
{
    if (!current_user.logged_in)
    {
        printf("Please log in first\n");
        return;
    }

    int note_id;
    printf("Enter the ID of the note you want to delete: ");
    scanf("%d", &note_id);

    if (note_id < 0 || note_id >= MAX_NOTES || notes[note_id] == NULL)
    {
        printf("Invalid note ID\n");
        return;
    }

    free(notes[note_id]->content);
    free(notes[note_id]);

    printf("Note deleted successfully\n");
}

void edit_note()
{
    if (!current_user.logged_in)
    {
        printf("Please log in first\n");
        return;
    }

    int note_id;
    char new_content[MAX_CONTENT_LENGTH];

    printf("Enter the ID of the note you want to edit: ");
    scanf("%d", &note_id);

    if (note_id < 0 || note_id >= MAX_NOTES || notes[note_id] == NULL)
    {
        printf("Invalid note ID\n");
        return;
    }

    printf("Enter new content: ");
    getchar();
    fgets(new_content, sizeof(new_content), stdin);
    new_content[strcspn(new_content, "\n")] = 0;

    free(notes[note_id]->content);
    notes[note_id]->content = (char *)malloc(strlen(new_content) + 1);
    strcpy(notes[note_id]->content, new_content);
    free(notes[note_id]->content);

    printf("Note edited successfully\n");
}

void print_flag()
{
    if (current_user.is_admin)
    {
        printf("Congratulations! Here's your flag: CTF{Th1s_1s_4_f4k3_fl4g}\n");
    }
    else
    {
        printf("Only admins can see the flag!\n");
    }
}

void print_user_info()
{
    if (!current_user.logged_in)
    {
        printf("Please log in first\n");
        return;
    }

    char info[256];
    snprintf(info, sizeof(info), "Username: %s, Admin: %d", current_user.username, current_user.is_admin);

    printf(info);
    printf("\n");
}

void create_super_note()
{
    if (!current_user.logged_in || !current_user.is_admin)
    {
        printf("Only admins can create super notes\n");
        return;
    }

    unsigned int size;
    printf("Enter the size of the super note: ");
    scanf("%u", &size);

    char *super_note = (char *)malloc(size + 1);
    if (super_note == NULL)
    {
        printf("Failed to allocate memory for super note\n");
        return;
    }

    printf("Super note created successfully\n");
    free(super_note);
}

int main()
{
    setvbuf(stdout, NULL, _IONBF, 0);
    setvbuf(stderr, NULL, _IONBF, 0);
    setvbuf(stdin, NULL, _IONBF, 0);

    int choice;

    while (1)
    {
        printf("\nWelcome to the Note Management System\n"
               "What would you like to do?\n"
               "1. Add new note\n"
               "2. View notes\n"
               "3. Delete note\n"
               "4. Edit note\n"
               "5. Print user info\n"
               "6. Create super note (Admin only)\n"
               "7. Print flag (Admin only)\n"
               "8. Exit\n"
               "Your choice: ");
        scanf("%d", &choice);

        switch (choice)
        {
        case 1:
            add_note();
            break;
        case 2:
            view_notes();
            break;
        case 3:
            delete_note();
            break;
        case 4:
            edit_note();
            break;
        case 5:
            print_user_info();
            break;
        case 6:
            create_super_note();
            break;
        case 7:
            print_flag();
            break;
        case 8:
            printf("Goodbye!\n");
            return 0;
        default:
            printf("Invalid choice\n");
            break;
        }
    }

    return 0;
}
