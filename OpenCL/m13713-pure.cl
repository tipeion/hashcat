/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

//#define NEW_SIMD_CODE

#undef  LOCAL_MEM_TYPE
#define LOCAL_MEM_TYPE LOCAL_MEM_TYPE_GLOBAL

#ifdef KERNEL_STATIC
#include "inc_vendor.h"
#include "inc_types.h"
#include "inc_common.cl"
#include "inc_simd.cl"
#include "inc_hash_ripemd160.cl"
#include "inc_cipher_aes.cl"
#include "inc_cipher_twofish.cl"
#include "inc_cipher_serpent.cl"
#include "inc_cipher_camellia.cl"
#include "inc_cipher_kuznyechik.cl"
#endif

typedef struct vc
{
  u32 salt_buf[32];
  u32 data_buf[112];
  u32 keyfile_buf[16];
  u32 signature;

  keyboard_layout_mapping_t keyboard_layout_mapping_buf[256];
  int                       keyboard_layout_mapping_cnt;

  int pim_multi; // 2048 for boot (not SHA-512 or Whirlpool), 1000 for others
  int pim_start;
  int pim_stop;

} vc_t;

#ifdef KERNEL_STATIC
#include "inc_truecrypt_keyfile.cl"
#include "inc_truecrypt_crc32.cl"
#include "inc_truecrypt_xts.cl"
#include "inc_veracrypt_xts.cl"
#endif

typedef struct vc_tmp
{
  u32 ipad[16];
  u32 opad[16];

  u32 dgst[64];
  u32 out[64];

  u32 pim_key[64];
  int pim; // marker for cracked

} vc_tmp_t;

DECLSPEC int check_header_0512 (GLOBAL_AS const vc_t *esalt_bufs, GLOBAL_AS u32 *key, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 key1[8];
  u32 key2[8];

  key1[0] = key[ 0];
  key1[1] = key[ 1];
  key1[2] = key[ 2];
  key1[3] = key[ 3];
  key1[4] = key[ 4];
  key1[5] = key[ 5];
  key1[6] = key[ 6];
  key1[7] = key[ 7];
  key2[0] = key[ 8];
  key2[1] = key[ 9];
  key2[2] = key[10];
  key2[3] = key[11];
  key2[4] = key[12];
  key2[5] = key[13];
  key2[6] = key[14];
  key2[7] = key[15];

  if (verify_header_aes        (esalt_bufs[0].data_buf, esalt_bufs[0].signature, key1, key2, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) == 1) return 0;
  if (verify_header_serpent    (esalt_bufs[0].data_buf, esalt_bufs[0].signature, key1, key2) == 1) return 0;
  if (verify_header_twofish    (esalt_bufs[0].data_buf, esalt_bufs[0].signature, key1, key2) == 1) return 0;
  if (verify_header_camellia   (esalt_bufs[0].data_buf, esalt_bufs[0].signature, key1, key2) == 1) return 0;
  if (verify_header_kuznyechik (esalt_bufs[0].data_buf, esalt_bufs[0].signature, key1, key2) == 1) return 0;

  return -1;
}

DECLSPEC int check_header_1024 (GLOBAL_AS const vc_t *esalt_bufs, GLOBAL_AS u32 *key, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 key1[8];
  u32 key2[8];
  u32 key3[8];
  u32 key4[8];

  key1[0] = key[ 0];
  key1[1] = key[ 1];
  key1[2] = key[ 2];
  key1[3] = key[ 3];
  key1[4] = key[ 4];
  key1[5] = key[ 5];
  key1[6] = key[ 6];
  key1[7] = key[ 7];
  key2[0] = key[ 8];
  key2[1] = key[ 9];
  key2[2] = key[10];
  key2[3] = key[11];
  key2[4] = key[12];
  key2[5] = key[13];
  key2[6] = key[14];
  key2[7] = key[15];
  key3[0] = key[16];
  key3[1] = key[17];
  key3[2] = key[18];
  key3[3] = key[19];
  key3[4] = key[20];
  key3[5] = key[21];
  key3[6] = key[22];
  key3[7] = key[23];
  key4[0] = key[24];
  key4[1] = key[25];
  key4[2] = key[26];
  key4[3] = key[27];
  key4[4] = key[28];
  key4[5] = key[29];
  key4[6] = key[30];
  key4[7] = key[31];

  if (verify_header_aes_twofish         (esalt_bufs[0].data_buf, esalt_bufs[0].signature, key1, key2, key3, key4, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) == 1) return 0;
  if (verify_header_serpent_aes         (esalt_bufs[0].data_buf, esalt_bufs[0].signature, key1, key2, key3, key4, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) == 1) return 0;
  if (verify_header_twofish_serpent     (esalt_bufs[0].data_buf, esalt_bufs[0].signature, key1, key2, key3, key4) == 1) return 0;
  if (verify_header_camellia_kuznyechik (esalt_bufs[0].data_buf, esalt_bufs[0].signature, key1, key2, key3, key4) == 1) return 0;
  if (verify_header_camellia_serpent    (esalt_bufs[0].data_buf, esalt_bufs[0].signature, key1, key2, key3, key4) == 1) return 0;
  if (verify_header_kuznyechik_aes      (esalt_bufs[0].data_buf, esalt_bufs[0].signature, key1, key2, key3, key4, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) == 1) return 0;
  if (verify_header_kuznyechik_twofish  (esalt_bufs[0].data_buf, esalt_bufs[0].signature, key1, key2, key3, key4) == 1) return 0;

  return -1;
}

DECLSPEC int check_header_1536 (GLOBAL_AS const vc_t *esalt_bufs, GLOBAL_AS u32 *key, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 key1[8];
  u32 key2[8];
  u32 key3[8];
  u32 key4[8];
  u32 key5[8];
  u32 key6[8];

  key1[0] = key[ 0];
  key1[1] = key[ 1];
  key1[2] = key[ 2];
  key1[3] = key[ 3];
  key1[4] = key[ 4];
  key1[5] = key[ 5];
  key1[6] = key[ 6];
  key1[7] = key[ 7];
  key2[0] = key[ 8];
  key2[1] = key[ 9];
  key2[2] = key[10];
  key2[3] = key[11];
  key2[4] = key[12];
  key2[5] = key[13];
  key2[6] = key[14];
  key2[7] = key[15];
  key3[0] = key[16];
  key3[1] = key[17];
  key3[2] = key[18];
  key3[3] = key[19];
  key3[4] = key[20];
  key3[5] = key[21];
  key3[6] = key[22];
  key3[7] = key[23];
  key4[0] = key[24];
  key4[1] = key[25];
  key4[2] = key[26];
  key4[3] = key[27];
  key4[4] = key[28];
  key4[5] = key[29];
  key4[6] = key[30];
  key4[7] = key[31];
  key5[0] = key[32];
  key5[1] = key[33];
  key5[2] = key[34];
  key5[3] = key[35];
  key5[4] = key[36];
  key5[5] = key[37];
  key5[6] = key[38];
  key5[7] = key[39];
  key6[0] = key[40];
  key6[1] = key[41];
  key6[2] = key[42];
  key6[3] = key[43];
  key6[4] = key[44];
  key6[5] = key[45];
  key6[6] = key[46];
  key6[7] = key[47];

  if (verify_header_aes_twofish_serpent         (esalt_bufs[0].data_buf, esalt_bufs[0].signature, key1, key2, key3, key4, key5, key6, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) == 1) return 0;
  if (verify_header_serpent_twofish_aes         (esalt_bufs[0].data_buf, esalt_bufs[0].signature, key1, key2, key3, key4, key5, key6, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) == 1) return 0;
  if (verify_header_kuznyechik_serpent_camellia (esalt_bufs[0].data_buf, esalt_bufs[0].signature, key1, key2, key3, key4, key5, key6) == 1) return 0;

  return -1;
}

DECLSPEC void hmac_ripemd160_run_V (u32x *w0, u32x *w1, u32x *w2, u32x *w3, u32x *ipad, u32x *opad, u32x *digest)
{
  digest[0] = ipad[0];
  digest[1] = ipad[1];
  digest[2] = ipad[2];
  digest[3] = ipad[3];
  digest[4] = ipad[4];

  ripemd160_transform_vector (w0, w1, w2, w3, digest);

  w0[0] = digest[0];
  w0[1] = digest[1];
  w0[2] = digest[2];
  w0[3] = digest[3];
  w1[0] = digest[4];
  w1[1] = 0x80;
  w1[2] = 0;
  w1[3] = 0;
  w2[0] = 0;
  w2[1] = 0;
  w2[2] = 0;
  w2[3] = 0;
  w3[0] = 0;
  w3[1] = 0;
  w3[2] = (64 + 20) * 8;
  w3[3] = 0;

  digest[0] = opad[0];
  digest[1] = opad[1];
  digest[2] = opad[2];
  digest[3] = opad[3];
  digest[4] = opad[4];

  ripemd160_transform_vector (w0, w1, w2, w3, digest);
}

KERNEL_FQ void m13713_init (KERN_ATTR_TMPS_ESALT (vc_tmp_t, vc_t))
{
  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);
  const u64 lsz = get_local_size (0);

  /**
   * keyboard layout shared
   */

  const int keyboard_layout_mapping_cnt = esalt_bufs[digests_offset].keyboard_layout_mapping_cnt;

  LOCAL_AS keyboard_layout_mapping_t s_keyboard_layout_mapping_buf[256];

  for (u32 i = lid; i < 256; i += lsz)
  {
    s_keyboard_layout_mapping_buf[i] = esalt_bufs[digests_offset].keyboard_layout_mapping_buf[i];
  }

  barrier (CLK_LOCAL_MEM_FENCE);

  if (gid >= gid_max) return;

  /**
   * base
   */

  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  w0[0] = pws[gid].i[ 0];
  w0[1] = pws[gid].i[ 1];
  w0[2] = pws[gid].i[ 2];
  w0[3] = pws[gid].i[ 3];
  w1[0] = pws[gid].i[ 4];
  w1[1] = pws[gid].i[ 5];
  w1[2] = pws[gid].i[ 6];
  w1[3] = pws[gid].i[ 7];
  w2[0] = pws[gid].i[ 8];
  w2[1] = pws[gid].i[ 9];
  w2[2] = pws[gid].i[10];
  w2[3] = pws[gid].i[11];
  w3[0] = pws[gid].i[12];
  w3[1] = pws[gid].i[13];
  w3[2] = pws[gid].i[14];
  w3[3] = pws[gid].i[15];

  const u32 pw_len = pws[gid].pw_len;

  execute_keyboard_layout_mapping (w0, w1, w2, w3, pw_len, s_keyboard_layout_mapping_buf, keyboard_layout_mapping_cnt);

  w0[0] = u8add (w0[0], esalt_bufs[digests_offset].keyfile_buf[ 0]);
  w0[1] = u8add (w0[1], esalt_bufs[digests_offset].keyfile_buf[ 1]);
  w0[2] = u8add (w0[2], esalt_bufs[digests_offset].keyfile_buf[ 2]);
  w0[3] = u8add (w0[3], esalt_bufs[digests_offset].keyfile_buf[ 3]);
  w1[0] = u8add (w1[0], esalt_bufs[digests_offset].keyfile_buf[ 4]);
  w1[1] = u8add (w1[1], esalt_bufs[digests_offset].keyfile_buf[ 5]);
  w1[2] = u8add (w1[2], esalt_bufs[digests_offset].keyfile_buf[ 6]);
  w1[3] = u8add (w1[3], esalt_bufs[digests_offset].keyfile_buf[ 7]);
  w2[0] = u8add (w2[0], esalt_bufs[digests_offset].keyfile_buf[ 8]);
  w2[1] = u8add (w2[1], esalt_bufs[digests_offset].keyfile_buf[ 9]);
  w2[2] = u8add (w2[2], esalt_bufs[digests_offset].keyfile_buf[10]);
  w2[3] = u8add (w2[3], esalt_bufs[digests_offset].keyfile_buf[11]);
  w3[0] = u8add (w3[0], esalt_bufs[digests_offset].keyfile_buf[12]);
  w3[1] = u8add (w3[1], esalt_bufs[digests_offset].keyfile_buf[13]);
  w3[2] = u8add (w3[2], esalt_bufs[digests_offset].keyfile_buf[14]);
  w3[3] = u8add (w3[3], esalt_bufs[digests_offset].keyfile_buf[15]);

  ripemd160_hmac_ctx_t ripemd160_hmac_ctx;

  ripemd160_hmac_init_64 (&ripemd160_hmac_ctx, w0, w1, w2, w3);

  tmps[gid].ipad[0] = ripemd160_hmac_ctx.ipad.h[0];
  tmps[gid].ipad[1] = ripemd160_hmac_ctx.ipad.h[1];
  tmps[gid].ipad[2] = ripemd160_hmac_ctx.ipad.h[2];
  tmps[gid].ipad[3] = ripemd160_hmac_ctx.ipad.h[3];
  tmps[gid].ipad[4] = ripemd160_hmac_ctx.ipad.h[4];

  tmps[gid].opad[0] = ripemd160_hmac_ctx.opad.h[0];
  tmps[gid].opad[1] = ripemd160_hmac_ctx.opad.h[1];
  tmps[gid].opad[2] = ripemd160_hmac_ctx.opad.h[2];
  tmps[gid].opad[3] = ripemd160_hmac_ctx.opad.h[3];
  tmps[gid].opad[4] = ripemd160_hmac_ctx.opad.h[4];

  ripemd160_hmac_update_global (&ripemd160_hmac_ctx, esalt_bufs[digests_offset].salt_buf, 64);

  for (u32 i = 0, j = 1; i < 48; i += 5, j += 1)
  {
    ripemd160_hmac_ctx_t ripemd160_hmac_ctx2 = ripemd160_hmac_ctx;

    w0[0] = j << 24;
    w0[1] = 0;
    w0[2] = 0;
    w0[3] = 0;
    w1[0] = 0;
    w1[1] = 0;
    w1[2] = 0;
    w1[3] = 0;
    w2[0] = 0;
    w2[1] = 0;
    w2[2] = 0;
    w2[3] = 0;
    w3[0] = 0;
    w3[1] = 0;
    w3[2] = 0;
    w3[3] = 0;

    ripemd160_hmac_update_64 (&ripemd160_hmac_ctx2, w0, w1, w2, w3, 4);

    ripemd160_hmac_final (&ripemd160_hmac_ctx2);

    tmps[gid].dgst[i + 0] = ripemd160_hmac_ctx2.opad.h[0];
    tmps[gid].dgst[i + 1] = ripemd160_hmac_ctx2.opad.h[1];
    tmps[gid].dgst[i + 2] = ripemd160_hmac_ctx2.opad.h[2];
    tmps[gid].dgst[i + 3] = ripemd160_hmac_ctx2.opad.h[3];
    tmps[gid].dgst[i + 4] = ripemd160_hmac_ctx2.opad.h[4];

    tmps[gid].out[i + 0] = tmps[gid].dgst[i + 0];
    tmps[gid].out[i + 1] = tmps[gid].dgst[i + 1];
    tmps[gid].out[i + 2] = tmps[gid].dgst[i + 2];
    tmps[gid].out[i + 3] = tmps[gid].dgst[i + 3];
    tmps[gid].out[i + 4] = tmps[gid].dgst[i + 4];
  }
}

KERNEL_FQ void m13713_loop (KERN_ATTR_TMPS_ESALT (vc_tmp_t, vc_t))
{
  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);
  const u64 lsz = get_local_size (0);

  /**
   * aes shared
   */

  #ifdef REAL_SHM

  LOCAL_AS u32 s_td0[256];
  LOCAL_AS u32 s_td1[256];
  LOCAL_AS u32 s_td2[256];
  LOCAL_AS u32 s_td3[256];
  LOCAL_AS u32 s_td4[256];

  LOCAL_AS u32 s_te0[256];
  LOCAL_AS u32 s_te1[256];
  LOCAL_AS u32 s_te2[256];
  LOCAL_AS u32 s_te3[256];
  LOCAL_AS u32 s_te4[256];

  for (u32 i = lid; i < 256; i += lsz)
  {
    s_td0[i] = td0[i];
    s_td1[i] = td1[i];
    s_td2[i] = td2[i];
    s_td3[i] = td3[i];
    s_td4[i] = td4[i];

    s_te0[i] = te0[i];
    s_te1[i] = te1[i];
    s_te2[i] = te2[i];
    s_te3[i] = te3[i];
    s_te4[i] = te4[i];
  }

  barrier (CLK_LOCAL_MEM_FENCE);

  #else

  CONSTANT_AS u32a *s_td0 = td0;
  CONSTANT_AS u32a *s_td1 = td1;
  CONSTANT_AS u32a *s_td2 = td2;
  CONSTANT_AS u32a *s_td3 = td3;
  CONSTANT_AS u32a *s_td4 = td4;

  CONSTANT_AS u32a *s_te0 = te0;
  CONSTANT_AS u32a *s_te1 = te1;
  CONSTANT_AS u32a *s_te2 = te2;
  CONSTANT_AS u32a *s_te3 = te3;
  CONSTANT_AS u32a *s_te4 = te4;

  #endif

  if (gid >= gid_max) return;

  // this is the pim range check
  // it is guaranteed that only 0 or 1 innerloops will match a "pim" mark (each 1000 iterations)
  // therefore the module limits the inner loop iteration count to 1000
  // if the key_pim is set, we know that we have to save and check the key for this pim

  const int pim_multi = esalt_bufs[digests_offset].pim_multi;
  const int pim_start = esalt_bufs[digests_offset].pim_start;
  const int pim_stop  = esalt_bufs[digests_offset].pim_stop;

  int pim    = 0;
  int pim_at = 0;

  for (u32 j = 0; j < loop_cnt; j++)
  {
    const int iter_abs = 1 + loop_pos + j;

    if ((iter_abs % pim_multi) == pim_multi - 1)
    {
      const int pim_cur = (iter_abs / pim_multi) + 1;

      if ((pim_cur >= pim_start) && (pim_cur <= pim_stop))
      {
        pim = pim_cur;

        pim_at = j;
      }
    }
  }

  // irregular pbkdf2 from here

  u32x ipad[5];
  u32x opad[5];

  ipad[0] = packv (tmps, ipad, gid, 0);
  ipad[1] = packv (tmps, ipad, gid, 1);
  ipad[2] = packv (tmps, ipad, gid, 2);
  ipad[3] = packv (tmps, ipad, gid, 3);
  ipad[4] = packv (tmps, ipad, gid, 4);

  opad[0] = packv (tmps, opad, gid, 0);
  opad[1] = packv (tmps, opad, gid, 1);
  opad[2] = packv (tmps, opad, gid, 2);
  opad[3] = packv (tmps, opad, gid, 3);
  opad[4] = packv (tmps, opad, gid, 4);

  for (u32 i = 0; i < 48; i += 5)
  {
    u32x dgst[5];
    u32x out[5];

    dgst[0] = packv (tmps, dgst, gid, i + 0);
    dgst[1] = packv (tmps, dgst, gid, i + 1);
    dgst[2] = packv (tmps, dgst, gid, i + 2);
    dgst[3] = packv (tmps, dgst, gid, i + 3);
    dgst[4] = packv (tmps, dgst, gid, i + 4);

    out[0] = packv (tmps, out, gid, i + 0);
    out[1] = packv (tmps, out, gid, i + 1);
    out[2] = packv (tmps, out, gid, i + 2);
    out[3] = packv (tmps, out, gid, i + 3);
    out[4] = packv (tmps, out, gid, i + 4);

    for (u32 j = 0; j < loop_cnt; j++)
    {
      u32x w0[4];
      u32x w1[4];
      u32x w2[4];
      u32x w3[4];

      w0[0] = dgst[0];
      w0[1] = dgst[1];
      w0[2] = dgst[2];
      w0[3] = dgst[3];
      w1[0] = dgst[4];
      w1[1] = 0x80;
      w1[2] = 0;
      w1[3] = 0;
      w2[0] = 0;
      w2[1] = 0;
      w2[2] = 0;
      w2[3] = 0;
      w3[0] = 0;
      w3[1] = 0;
      w3[2] = (64 + 20) * 8;
      w3[3] = 0;

      hmac_ripemd160_run_V (w0, w1, w2, w3, ipad, opad, dgst);

      out[0] ^= dgst[0];
      out[1] ^= dgst[1];
      out[2] ^= dgst[2];
      out[3] ^= dgst[3];
      out[4] ^= dgst[4];

      // this iteration creates a valid pim

      if (j == pim_at)
      {
        tmps[gid].pim_key[i + 0] = out[0];
        tmps[gid].pim_key[i + 1] = out[1];
        tmps[gid].pim_key[i + 2] = out[2];
        tmps[gid].pim_key[i + 3] = out[3];
        tmps[gid].pim_key[i + 4] = out[4];
      }
    }

    unpackv (tmps, dgst, gid, i + 0, dgst[0]);
    unpackv (tmps, dgst, gid, i + 1, dgst[1]);
    unpackv (tmps, dgst, gid, i + 2, dgst[2]);
    unpackv (tmps, dgst, gid, i + 3, dgst[3]);
    unpackv (tmps, dgst, gid, i + 4, dgst[4]);

    unpackv (tmps, out, gid, i + 0, out[0]);
    unpackv (tmps, out, gid, i + 1, out[1]);
    unpackv (tmps, out, gid, i + 2, out[2]);
    unpackv (tmps, out, gid, i + 3, out[3]);
    unpackv (tmps, out, gid, i + 4, out[4]);
  }

  if (pim == 0) return;

  if (check_header_0512 (esalt_bufs, tmps[gid].pim_key, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) != -1) tmps[gid].pim = pim;
  if (check_header_1024 (esalt_bufs, tmps[gid].pim_key, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) != -1) tmps[gid].pim = pim;
  if (check_header_1536 (esalt_bufs, tmps[gid].pim_key, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) != -1) tmps[gid].pim = pim;
}

KERNEL_FQ void m13713_comp (KERN_ATTR_TMPS_ESALT (vc_tmp_t, vc_t))
{
  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);
  const u64 lsz = get_local_size (0);

  /**
   * aes shared
   */

  #ifdef REAL_SHM

  LOCAL_AS u32 s_td0[256];
  LOCAL_AS u32 s_td1[256];
  LOCAL_AS u32 s_td2[256];
  LOCAL_AS u32 s_td3[256];
  LOCAL_AS u32 s_td4[256];

  LOCAL_AS u32 s_te0[256];
  LOCAL_AS u32 s_te1[256];
  LOCAL_AS u32 s_te2[256];
  LOCAL_AS u32 s_te3[256];
  LOCAL_AS u32 s_te4[256];

  for (u32 i = lid; i < 256; i += lsz)
  {
    s_td0[i] = td0[i];
    s_td1[i] = td1[i];
    s_td2[i] = td2[i];
    s_td3[i] = td3[i];
    s_td4[i] = td4[i];

    s_te0[i] = te0[i];
    s_te1[i] = te1[i];
    s_te2[i] = te2[i];
    s_te3[i] = te3[i];
    s_te4[i] = te4[i];
  }

  barrier (CLK_LOCAL_MEM_FENCE);

  #else

  CONSTANT_AS u32a *s_td0 = td0;
  CONSTANT_AS u32a *s_td1 = td1;
  CONSTANT_AS u32a *s_td2 = td2;
  CONSTANT_AS u32a *s_td3 = td3;
  CONSTANT_AS u32a *s_td4 = td4;

  CONSTANT_AS u32a *s_te0 = te0;
  CONSTANT_AS u32a *s_te1 = te1;
  CONSTANT_AS u32a *s_te2 = te2;
  CONSTANT_AS u32a *s_te3 = te3;
  CONSTANT_AS u32a *s_te4 = te4;

  #endif

  if (gid >= gid_max) return;

  if (tmps[gid].pim)
  {
    if (atomic_inc (&hashes_shown[0]) == 0)
    {
      mark_hash (plains_buf, d_return_buf, salt_pos, digests_cnt, 0, 0, gid, 0, tmps[gid].pim, 0);
    }
  }
  else
  {
    if (check_header_0512 (esalt_bufs, tmps[gid].out, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) != -1)
    {
      if (atomic_inc (&hashes_shown[0]) == 0)
      {
        mark_hash (plains_buf, d_return_buf, salt_pos, digests_cnt, 0, 0, gid, 0, 0, 0);
      }
    }

    if (check_header_1024 (esalt_bufs, tmps[gid].out, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) != -1)
    {
      if (atomic_inc (&hashes_shown[0]) == 0)
      {
        mark_hash (plains_buf, d_return_buf, salt_pos, digests_cnt, 0, 0, gid, 0, 0, 0);
      }
    }

    if (check_header_1536 (esalt_bufs, tmps[gid].out, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4) != -1)
    {
      if (atomic_inc (&hashes_shown[0]) == 0)
      {
        mark_hash (plains_buf, d_return_buf, salt_pos, digests_cnt, 0, 0, gid, 0, 0, 0);
      }
    }
  }
}
