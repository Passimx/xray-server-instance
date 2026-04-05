import { ArrayMinSize, IsArray, IsString } from 'class-validator';

export class CommandsDto {
  @IsString({ each: true })
  @IsArray()
  @ArrayMinSize(1)
  readonly commands: string[];
}
