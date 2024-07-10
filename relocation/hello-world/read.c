#include <stdio.h>

/* Opens the file that contains the helper function relocations and rewrites the binary
 * Uses placeholder functions for querying kernel symbol address and calculations etc
 */

int main() {
    FILE* fp = fopen("rel", "r+b");
    int relocation_offset, jit_offset;
    printf("Initial position is %ld\n", ftell(fp));
    fread(&relocation_offset, 4, 1, fp);
    fread(&jit_offset, 4, 1, fp);
    printf("Relocation offset is %d\nJIT offset is %d\n", relocation_offset, jit_offset);

    int relocs = (jit_offset - relocation_offset) / 8;
    printf("%d relocations\n", relocs); 

    fseek(fp, 0, relocation_offset);
    int next;
    fread(&next, 4, 1, fp);
    printf("Next is at %d\n", next);
    int relo;
    fread(&relo, 4, 1, fp);
    printf("Relo is %8x\n", relo);

    fseek(fp, next + jit_offset + 1, SEEK_SET);
    printf("At byte %d in file\n", ftell(fp));
    //printf("Next is at %d\n", next);
    unsigned char * pt = &relo;
    for (int i = 0; i < 4; i++) {
        fwrite(pt+i, 1, 1, fp);
    }
    //fwrite(&relo, 4, 1, fp);
    fclose(fp);
    
    //char buff[4]; 
    //int length;
    //const int relocation_entry = 8;
    //fread(&buff, 1, 4, relocation_table);
    //fseek(relocation_table, 0, SEEK_SET);
    //fread(&length, 4, 1, relocation_table);
    //printf("Lenght is %d\n", length);
    //for (int i = 0; i < 4; i++) {
    //    printf("Val %d is %d\n", i, buff[i]);
    //
    return 0;
    
}

unsigned long kall_lookup_name(const char* name) {
    return 0xffffffffff000000;
}
