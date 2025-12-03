from uuid import UUID


def convert_uuids_to_strings(data: dict) -> dict:
    def convert_value(value):
        if isinstance(value, UUID):
            return str(value)
        elif isinstance(value, dict):
            return {k: convert_value(v) for k, v in value.items()}
        elif isinstance(value, list):
            return [convert_value(item) for item in value]
        else:
            return value
    
    return {k: convert_value(v) for k, v in data.items()}