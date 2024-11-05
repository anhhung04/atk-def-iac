#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "./lib/sqlite3.h"

#define MAX_SSN_LENGTH 50
#define MAX_CONTENT_LENGTH 200
#define MAX_SQL_LENGTH 400

#define DB_PATH "/tmp/main.db"

int query_callback(void *NotUsed, int argc, char **argv, char **azColName)
{
    printf("- %s\n", argv[2]);
    return 0;
}

void exec_sqlite(const char *sql, sqlite3 *db, int (*callback)(void *, int, char **, char **))
{
    char *zErrMsg = 0;
    int rc = sqlite3_exec(db, sql, callback, 0, &zErrMsg);
    if (rc != SQLITE_OK)
    {
        fprintf(stderr, "SQL error: %s\n", zErrMsg);
        sqlite3_free(zErrMsg);
    }
}

sqlite3 *init()
{
    sqlite3 *db;
    int rc = sqlite3_open(DB_PATH, &db);
    if (rc)
    {
        fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
        exit(1);
    }
    exec_sqlite("CREATE TABLE IF NOT EXISTS docs(id INTEGER, ssn TEXT, content TEXT);", db, NULL);
    return db;
}

int is_attacker(const char *s)
{
    const char *blacklist[] = {"'", "\"", "/*", "*/", "UNION", "SELECT", "DROP", "DELETE", "UPDATE"};
    int num_blacklist = sizeof(blacklist) / sizeof(blacklist[0]);

    for (int i = 0; i < num_blacklist; i++)
    {
        if (!strcasecmp(s, blacklist[i]))
        {
            return 1;
        }
    }

    return 0;
}

void add_document(sqlite3 *db)
{
    char ssn[MAX_SSN_LENGTH];
    char content[MAX_CONTENT_LENGTH];
    char sql[MAX_SQL_LENGTH];

    printf("Enter your SSN: ");
    scanf("%49s", ssn);
    printf("Enter your content: ");
    getchar();
    fgets(content, sizeof(content), stdin);
    content[strcspn(content, "\n")] = 0;

    snprintf(sql, sizeof(sql), "INSERT INTO docs VALUES(1, '%s', '%s');", ssn, content);
    exec_sqlite(sql, db, NULL);
    printf("Document added\n");
}

void view_document(sqlite3 *db)
{
    char ssn_column[0x100] = "ssn\0";
    char buffer[MAX_SSN_LENGTH];
    char sql[MAX_SQL_LENGTH];
    printf("Enter your SSN: ");
    scanf("%49s", buffer);

    if (is_attacker(buffer))
    {
        printf("Invalid input\n");
        return;
    }

    printf("Your contents:\n");
    snprintf(sql, sizeof(sql), "SELECT * FROM docs WHERE %s='%s';", ssn_column, buffer);
    exec_sqlite(sql, db, query_callback);
    printf("End of contents\n");
}

int main()
{
    setvbuf(stdin, NULL, _IONBF, 0);
    setvbuf(stdout, NULL, _IONBF, 0);
    setvbuf(stderr, NULL, _IONBF, 0);

    sqlite3 *db = init();
    int choice;

    printf("Welcome to the document management system\n"
           "What would you like to do?\n"
           "1. Add new document\n"
           "2. View document\n"
           "Your choice: ");
    scanf("%d", &choice);

    switch (choice)
    {
    case 1:
        add_document(db);
        break;
    case 2:
        view_document(db);
        break;
    default:
        printf("Invalid choice\n");
        break;
    }

    return sqlite3_close(db);
}