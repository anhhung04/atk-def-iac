#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "./lib/sqlite3.h"

int query_callback(void *NotUsed, int argc, char **argv, char **azColName)
{
    printf("- %s\n", argv[2]);
    return 0;
}

void exec_sqlite(char *sql, sqlite3 *db, void *callback)
{
    char *zErrMsg = 0;
    int rc;
    rc = sqlite3_exec(db, sql, callback, 0, &zErrMsg);
    if (rc != SQLITE_OK)
    {
        printf("SQL error: %s\n", zErrMsg);
        sqlite3_free(zErrMsg);
    }
}

sqlite3 *init()
{
    setvbuf(stdin, NULL, _IONBF, 0);
    setvbuf(stdout, NULL, _IONBF, 0);
    setvbuf(stderr, NULL, _IONBF, 0);
    sqlite3 *db;
    char *zErrMsg = 0;
    int rc;
    rc = sqlite3_open("/tmp/main.db", &db);
    if (rc)
    {
        printf("Can't open database: %s\n", sqlite3_errmsg(db));
        exit(1);
    }
    exec_sqlite("CREATE TABLE IF NOT EXISTS docs(id INTEGER, ssn TEXT, content TEXT);", db, NULL);
    return db;
}

int is_attacker(char *s)
{
    return strstr(s, "'") != NULL;
}

int main(int argc, char *argv[])
{
    sqlite3 *db = init();
    int choice;
    printf("Welcome to the document management system\nWhat would you like to do?\n1. Add new document\n2. View document\nYour choice: ");
    scanf("%d", &choice);
    switch (choice)
    {
    case 1:
    {
        char ssn[50];
        char content[200];
        char sql[300];
        printf("Enter your SSN: ");
        scanf("%s", ssn);
        printf("Enter your content: ");
        read(0, content, 200);
        sprintf(sql, "INSERT INTO docs VALUES(1, '%s', '%s');", ssn, content);
        exec_sqlite(sql, db, NULL);
        printf("Document added\n");
        break;
    }
    case 2:
    {
        char ssn_column[4] = "ssn\0";
        char buffer[50];
        printf("Enter your SSN: ");
        scanf("%s", buffer);
        if (is_attacker(buffer))
        {
            printf("Invalid input\n");
            return 0;
        }
        char sql[150];
        printf("Your contents:\n");
        sprintf(sql, "SELECT * FROM docs WHERE %s='%s';", ssn_column, buffer);
        exec_sqlite(sql, db, query_callback);
        printf("End of contents\n");
        break;
    }
    default:
    {
        printf("Invalid choice\n");
        break;
    }
    }
    return sqlite3_close(db);
};