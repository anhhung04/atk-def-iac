#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "./lib/sqlite3.h"

#define MAX_USERNAME_LENGTH 50
#define MAX_PASSWORD_LENGTH 50
#define MAX_CONTENT_LENGTH 1280
#define MAX_SQL_LENGTH 2048

#define DB_PATH "/tmp/notes.db"

typedef struct
{
    char username[MAX_USERNAME_LENGTH];
    int logged_in;
    int is_admin;
} User;

User current_user = {"", 0, 0};

sqlite3 *db;

void vulnerable_memcpy(char *dest, const char *src, size_t n)
{
    while (n--)
    {
        *dest++ = *src++;
    }
}

void init_database()
{
    int rc = sqlite3_open(DB_PATH, &db);
    if (rc != SQLITE_OK)
    {
        fprintf(stderr, "Cannot open database: %s\n", sqlite3_errmsg(db));
        sqlite3_close(db);
        exit(1);
    }

    char *sql = "CREATE TABLE IF NOT EXISTS users (username TEXT PRIMARY KEY, password TEXT, is_admin INTEGER);"
                "CREATE TABLE IF NOT EXISTS notes (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, content TEXT);";
    char *err_msg = 0;
    rc = sqlite3_exec(db, sql, 0, 0, &err_msg);

    if (rc != SQLITE_OK)
    {
        fprintf(stderr, "SQL error: %s\n", err_msg);
        sqlite3_free(err_msg);
        sqlite3_close(db);
        exit(1);
    }
}

void register_user()
{
    char username[MAX_USERNAME_LENGTH];
    char password[MAX_PASSWORD_LENGTH];

    printf("Enter username: ");
    scanf("%49s", username);
    printf("Enter password: ");
    scanf("%49s", password);

    char sql[MAX_SQL_LENGTH];
    snprintf(sql, sizeof(sql), "INSERT INTO users (username, password, is_admin) VALUES ('%s', '%s', 0);", username, password);

    char *err_msg = 0;
    int rc = sqlite3_exec(db, sql, 0, 0, &err_msg);

    if (rc != SQLITE_OK)
    {
        fprintf(stderr, "SQL error: %s\n", err_msg);
        sqlite3_free(err_msg);
    }
    else
    {
        printf("User registered successfully\n");
    }
}

void login()
{
    char username[MAX_USERNAME_LENGTH];
    char password[MAX_PASSWORD_LENGTH];

    printf("Enter username: ");
    scanf("%49s", username);
    printf("Enter password: ");
    scanf("%49s", password);

    char sql[MAX_SQL_LENGTH];
    snprintf(sql, sizeof(sql), "SELECT is_admin FROM users WHERE username = '%s' AND password = '%s';", username, password);

    sqlite3_stmt *stmt;
    int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, 0);

    if (rc != SQLITE_OK)
    {
        fprintf(stderr, "Failed to execute statement: %s\n", sqlite3_errmsg(db));
        return;
    }

    rc = sqlite3_step(stmt);

    if (rc == SQLITE_ROW)
    {
        strncpy(current_user.username, username, MAX_USERNAME_LENGTH);
        current_user.logged_in = 1;
        current_user.is_admin = sqlite3_column_int(stmt, 0);
        printf("Login successful\n");
    }
    else
    {
        printf("Invalid username or password\n");
    }

    sqlite3_finalize(stmt);
}

void logout()
{
    memset(&current_user, 0, sizeof(User));
    printf("Logged out successfully\n");
}

void add_note()
{
    if (!current_user.logged_in)
    {
        printf("Please log in first\n");
        return;
    }

    char content[MAX_CONTENT_LENGTH];
    printf("Enter your note content: ");
    fgets(content, sizeof(content), stdin);
    content[strcspn(content, "\n")] = 0;

    char sql[MAX_SQL_LENGTH];
    snprintf(sql, sizeof(sql), "INSERT INTO notes (username, content) VALUES ('%s', '%s');", current_user.username, content);

    char *err_msg = 0;
    int rc = sqlite3_exec(db, sql, 0, 0, &err_msg);

    if (rc != SQLITE_OK)
    {
        fprintf(stderr, "SQL error: %s\n", err_msg);
        sqlite3_free(err_msg);
    }
    else
    {
        sqlite3_int64 last_id = sqlite3_last_insert_rowid(db);
        printf("Note added successfully with ID: %lld\n", last_id);
    }
}

void view_notes()
{
    if (!current_user.logged_in)
    {
        printf("Please log in first\n");
        return;
    }

    char sql[MAX_SQL_LENGTH];
    snprintf(sql, sizeof(sql), "SELECT id, content FROM notes WHERE username = '%s';", current_user.username);

    sqlite3_stmt *stmt;
    int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, 0);

    if (rc != SQLITE_OK)
    {
        fprintf(stderr, "Failed to execute statement: %s\n", sqlite3_errmsg(db));
        return;
    }

    printf("Notes:\n");
    while (sqlite3_step(stmt) == SQLITE_ROW)
    {
        int id = sqlite3_column_int(stmt, 0);
        const unsigned char *content = sqlite3_column_text(stmt, 1);
        printf("Note ID: %d\n", id);
        printf("Content: %s\n", content);
        printf("--------------------\n");
    }

    sqlite3_finalize(stmt);
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

    char sql[MAX_SQL_LENGTH];
    snprintf(sql, sizeof(sql), "DELETE FROM notes WHERE id = %d AND username = '%s';", note_id, current_user.username);

    char *err_msg = 0;
    int rc = sqlite3_exec(db, sql, 0, 0, &err_msg);

    if (rc != SQLITE_OK)
    {
        fprintf(stderr, "SQL error: %s\n", err_msg);
        sqlite3_free(err_msg);
    }
    else
    {
        printf("Note deleted successfully\n");
    }
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

    printf("Enter new content: ");
    getchar();
    fgets(new_content, sizeof(new_content), stdin);
    new_content[strcspn(new_content, "\n")] = 0;

    char sql[MAX_SQL_LENGTH];
    snprintf(sql, sizeof(sql), "UPDATE notes SET content = '%s' WHERE id = %d AND username = '%s';", new_content, note_id, current_user.username);

    char *err_msg = 0;
    int rc = sqlite3_exec(db, sql, 0, 0, &err_msg);

    if (rc != SQLITE_OK)
    {
        fprintf(stderr, "SQL error: %s\n", err_msg);
        sqlite3_free(err_msg);
    }
    else
    {
        printf("Note edited successfully\n");
    }
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

    char *super_note = (char *)malloc(size);
    if (super_note == NULL)
    {
        printf("Failed to allocate memory for super note\n");
        return;
    }

    printf("Enter super note content: ");
    scanf("%s", super_note);

    printf("Super note created successfully\n");
    free(super_note);
}

int main()
{
    setvbuf(stdout, NULL, _IONBF, 0);
    setvbuf(stderr, NULL, _IONBF, 0);
    setvbuf(stdin, NULL, _IONBF, 0);

    init_database();

    int choice;

    while (1)
    {
        printf("\nWelcome to the Note Management System\n"
               "What would you like to do?\n"
               "1. Register\n"
               "2. Login\n"
               "3. Add new note\n"
               "4. View notes\n"
               "5. Delete note\n"
               "6. Edit note\n"
               "7. Print user info\n"
               "8. Create super note (Admin only)\n"
               "9. Print flag (Admin only)\n"
               "10. Logout\n"
               "11. Exit\n"
               "Your choice: ");
        scanf("%d", &choice);
        getchar();

        switch (choice)
        {
        case 1:
            register_user();
            break;
        case 2:
            login();
            break;
        case 3:
            add_note();
            break;
        case 4:
            view_notes();
            break;
        case 5:
            delete_note();
            break;
        case 6:
            edit_note();
            break;
        case 7:
            print_user_info();
            break;
        case 8:
            create_super_note();
            break;
        case 9:
            print_flag();
            break;
        case 10:
            logout();
            break;
        case 11:
            printf("Goodbye!\n");
            sqlite3_close(db);
            return 0;
        default:
            printf("Invalid choice\n");
            break;
        }
    }
    return 0;
}